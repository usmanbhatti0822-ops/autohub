import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../reviews/data/reviews_repository.dart';
import '../providers/rentals_provider.dart';

class RentalDetailScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const RentalDetailScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends ConsumerState<RentalDetailScreen> {
  DateTimeRange? _range;
  bool _withDriver = false;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  void _proceedToSummary() {
    if (_range == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick your rental dates first')));
      return;
    }
    final vehicle = ref.read(rentalVehicleDetailProvider(widget.vehicleId)).value;
    if (vehicle == null) return;
    context.push('/booking-summary', extra: {
      'vehicle': vehicle,
      'range': _range,
      'withDriver': _withDriver,
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(rentalVehicleDetailProvider(widget.vehicleId));

    return Scaffold(
      body: vehicleAsync.when(
        data: (v) {
          final days = _range == null
              ? 0
              : _range!.end.difference(_range!.start).inDays.clamp(1, 999);
          final total = days * v.dailyRate;
          final ratingAsync = ref.watch(userRatingProvider(v.ownerId));

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 260,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: v.photoUrls.isNotEmpty
                            ? PageView(
                                children: v.photoUrls
                                    .map((url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
                                    .toList(),
                              )
                            : Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.directions_car, size: 64, color: Colors.white70),
                              ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(v.title, style: Theme.of(context).textTheme.headlineSmall),
                                ),
                                CategoryChip(category: v.category),
                              ],
                            ).animate().fadeIn(),
                            const SizedBox(height: 4),
                            Text('${pkrFormat.format(v.dailyRate)} / day',
                                style: const TextStyle(
                                    color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20)),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _SpecChip(icon: Icons.event_seat_outlined, label: '${v.seats} seats'),
                                _SpecChip(icon: Icons.sensor_door_outlined, label: '${v.doors} doors'),
                                _SpecChip(icon: Icons.settings_outlined, label: v.transmission),
                                _SpecChip(icon: Icons.local_gas_station_outlined, label: v.fuelType),
                                if (v.driverAvailable)
                                  const _SpecChip(icon: Icons.person_outline_rounded, label: 'Driver available'),
                              ],
                            ).animate().fadeIn(delay: 100.ms),
                            if (v.features.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text('Features', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.xs,
                                runSpacing: AppSpacing.xs,
                                children: v.features
                                    .map((f) => Chip(label: Text(f), visualDensity: VisualDensity.compact))
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            Text('Pickup location', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Expanded(child: Text(v.pickupLocation)),
                              ],
                            ),
                            if (v.description != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Text('Description', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(v.description!),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            ratingAsync.when(
                              data: (r) => Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.storefront_outlined, color: AppColors.textSecondary),
                                    const SizedBox(width: AppSpacing.sm),
                                    const Text('Owner rating', style: TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    RatingStars(rating: r.average, count: r.count),
                                  ],
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (e, st) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(AppRadii.lg),
                                boxShadow: AppShadows.card,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Select rental dates', style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: AppSpacing.sm),
                                  OutlinedButton.icon(
                                    onPressed: _pickDateRange,
                                    icon: const Icon(Icons.date_range, size: 18),
                                    label: Text(
                                      _range == null
                                          ? 'Choose dates'
                                          : '${monthDayFormat.format(_range!.start)} - ${monthDayFormat.format(_range!.end)}',
                                    ),
                                  ),
                                  if (v.driverAvailable)
                                    CheckboxListTile(
                                      value: _withDriver,
                                      onChanged: (val) => setState(() => _withDriver = val ?? false),
                                      title: const Text('Rent with driver'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  if (days > 0) ...[
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('$days day(s)'),
                                        Text(pkrFormat.format(total), style: const TextStyle(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorState(onRetry: () => ref.invalidate(rentalVehicleDetailProvider(widget.vehicleId))),
      ),
      bottomNavigationBar: vehicleAsync.maybeWhen(
        data: (v) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToSummary,
                child: const Text('Continue to Booking'),
              ),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
