import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../domain/car_listing.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_card.dart';
import '../widgets/featured_card.dart';

const _categories = ['economy', 'hatchback', 'sedan', 'suv', 'luxury'];
const _categoryIcons = {
  'economy': Icons.savings_outlined,
  'hatchback': Icons.directions_car_outlined,
  'sedan': Icons.directions_car_filled_outlined,
  'suv': Icons.airport_shuttle_outlined,
  'luxury': Icons.diamond_outlined,
};

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(listingsProvider);
    final filters = ref.watch(listingFiltersProvider);
    final user = ref.watch(authProvider).user;
    final List<CarListing> featured = listingsAsync.maybeWhen(
      data: (items) => items.where((l) => l.isVerified).take(6).toList(),
      orElse: () => const [],
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/post-listing'),
        icon: const Icon(Icons.add),
        label: const Text('Sell a car'),
        backgroundColor: AppColors.accent,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(listingsProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, ${(user?.fullName ?? '').split(' ').first.isNotEmpty ? user!.fullName!.split(' ').first : 'there'} 👋',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                                Text('Find your next car',
                                    style: Theme.of(context).textTheme.headlineSmall),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/profile'),
                            child: AppAvatar(imageUrl: user?.avatarUrl, name: user?.displayName ?? '?', size: 42),
                          ),
                        ],
                      ).animate().fadeIn(),
                      const SizedBox(height: AppSpacing.md),
                      Row(
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
                              onSubmitted: (value) {
                                ref.read(listingFiltersProvider.notifier).state =
                                    filters.copyWith(make: value);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterButton(active: filters.isActive, onTap: () async {
                            final result = await showFilterSheet(
                              context,
                              initial: FilterSheetResult(
                                category: filters.category,
                                transmission: filters.transmission,
                                fuelType: filters.fuelType,
                                minPrice: filters.minPrice,
                                maxPrice: filters.maxPrice,
                                sortBy: filters.sortBy,
                              ),
                            );
                            if (result != null) {
                              ref.read(listingFiltersProvider.notifier).state = ListingFilters(
                                make: filters.make,
                                category: result.category,
                                transmission: result.transmission,
                                fuelType: result.fuelType,
                                minPrice: result.minPrice,
                                maxPrice: result.maxPrice,
                                sortBy: result.sortBy,
                              );
                            }
                          }),
                        ],
                      ).animate().fadeIn(delay: 80.ms),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                          itemBuilder: (context, i) {
                            final c = _categories[i];
                            return CategoryFilterChip(
                              label: c[0].toUpperCase() + c.substring(1),
                              icon: _categoryIcons[c] ?? Icons.directions_car,
                              selected: filters.category == c,
                              onTap: () => ref.read(listingFiltersProvider.notifier).state =
                                  filters.copyWith(category: filters.category == c ? null : c),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 120.ms),
                      const SizedBox(height: AppSpacing.md),
                      _PromoBanner(onTap: () => context.push('/rentals'))
                          .animate()
                          .fadeIn(delay: 160.ms)
                          .slideY(begin: 0.08, end: 0),
                    ],
                  ),
                ),
              ),
              if (featured.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
                    child: Text('Featured Cars', style: Theme.of(context).textTheme.titleLarge),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      itemCount: featured.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, i) => FeaturedCard(
                        listing: featured[i],
                        onTap: () => context.push('/listing/${featured[i].id}'),
                      ),
                    ),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xs),
                  child: Text('All Listings', style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              listingsAsync.when(
                data: (listings) {
                  if (listings.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.directions_car_outlined,
                        title: 'No cars match your filters',
                        message: 'Try adjusting your search or filters.',
                        actionLabel: 'Clear filters',
                        onAction: () => ref.read(listingFiltersProvider.notifier).state = const ListingFilters(),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ListingCard(
                          listing: listings[i],
                          animationIndex: i,
                          onTap: () => context.push('/listing/${listings[i].id}'),
                        ),
                        childCount: listings.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => const SkeletonListingCard(),
                      childCount: 6,
                    ),
                  ),
                ),
                error: (e, st) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorState(onRetry: () => ref.invalidate(listingsProvider)),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

class _PromoBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PromoBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: AppGradients.accent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Need a car for a few days?',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Browse rentals or list your own car and earn',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: const Text('Explore', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
