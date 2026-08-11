import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/skeletons.dart';
import '../providers/rentals_provider.dart';

const _categories = ['economy', 'hatchback', 'sedan', 'suv', 'luxury'];
const _categoryIcons = {
  'economy': Icons.savings_outlined,
  'hatchback': Icons.directions_car_outlined,
  'sedan': Icons.directions_car_filled_outlined,
  'suv': Icons.airport_shuttle_outlined,
  'luxury': Icons.diamond_outlined,
};

class RentalBrowseScreen extends ConsumerWidget {
  const RentalBrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(rentalVehiclesProvider);
    final params = ref.watch(rentalSearchParamsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rent a Car')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/list-for-rent'),
        icon: const Icon(Icons.add),
        label: const Text('List your car'),
        backgroundColor: AppColors.accent,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(rentalVehiclesProvider),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded),
                          hintText: 'Search make, model...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) => ref.read(rentalSearchParamsProvider.notifier).state =
                            params.copyWith(make: value),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterButton(
                      active: params.isActive,
                      onTap: () async {
                        final result = await showFilterSheet(
                          context,
                          showFuelType: false,
                          priceLabelSuffix: '/day',
                          initial: FilterSheetResult(
                            category: params.category,
                            transmission: params.transmission,
                            minPrice: params.minPrice,
                            maxPrice: params.maxPrice,
                            sortBy: params.sortBy,
                          ),
                        );
                        if (result != null) {
                          ref.read(rentalSearchParamsProvider.notifier).state = RentalSearchParams(
                            make: params.make,
                            startDate: params.startDate,
                            endDate: params.endDate,
                            category: result.category,
                            transmission: result.transmission,
                            minPrice: result.minPrice,
                            maxPrice: result.maxPrice,
                            sortBy: result.sortBy,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, i) {
                    final c = _categories[i];
                    return CategoryFilterChip(
                      label: c[0].toUpperCase() + c.substring(1),
                      icon: _categoryIcons[c] ?? Icons.directions_car,
                      selected: params.category == c,
                      onTap: () => ref.read(rentalSearchParamsProvider.notifier).state =
                          params.copyWith(category: params.category == c ? null : c),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: vehiclesAsync.when(
                  data: (vehicles) {
                    if (vehicles.isEmpty) {
                      return EmptyState(
                        icon: Icons.car_rental_outlined,
                        title: 'No rentals match your filters',
                        message: 'Try a different city, category, or price range.',
                        actionLabel: 'Clear filters',
                        onAction: () => ref.read(rentalSearchParamsProvider.notifier).state =
                            const RentalSearchParams(),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 90),
                      itemCount: vehicles.length,
                      itemBuilder: (context, i) {
                        final v = vehicles[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            boxShadow: AppShadows.soft,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => context.push('/rental/${v.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadii.sm),
                                    child: v.photoUrls.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: v.photoUrls.first,
                                            width: 96,
                                            height: 76,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 96,
                                            height: 76,
                                            color: AppColors.surface,
                                            child: const Icon(Icons.directions_car, color: AppColors.textTertiary),
                                          ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(v.title,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                                            ),
                                            CategoryChip(category: v.category),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text('${v.city} • ${v.transmission}',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${pkrFormat.format(v.dailyRate)}/day',
                                              style: const TextStyle(
                                                  color: AppColors.primary, fontWeight: FontWeight.w800),
                                            ),
                                            if (v.driverAvailable) ...[
                                              const SizedBox(width: 6),
                                              const Icon(Icons.person, size: 14, color: AppColors.success),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: (40 * i).ms).slideX(begin: 0.05, end: 0);
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 4,
                    itemBuilder: (_, __) => const SkeletonRowCard(),
                  ),
                  error: (e, st) => ErrorState(onRetry: () => ref.invalidate(rentalVehiclesProvider)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FilterButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: active ? Colors.transparent : AppColors.outline),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(Icons.tune_rounded, color: active ? Colors.white : AppColors.textPrimary),
          ),
        ),
        if (active)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }
}
