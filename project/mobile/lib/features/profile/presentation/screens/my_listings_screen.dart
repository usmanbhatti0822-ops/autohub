import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../marketplace/data/listings_repository.dart';
import '../../../marketplace/domain/car_listing.dart';
import '../../../rentals/data/rentals_repository.dart';
import '../../../rentals/domain/rental_models.dart';

final _myListingsProvider = FutureProvider.autoDispose<List<CarListing>>((ref) {
  return ref.read(listingsRepositoryProvider).myListings();
});

final _myVehiclesProvider = FutureProvider.autoDispose<List<RentalVehicle>>((ref) {
  return ref.read(rentalsRepositoryProvider).myVehicles();
});

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Listings & Vehicles'),
          bottom: const TabBar(tabs: [Tab(text: 'For Sale'), Tab(text: 'For Rent')]),
        ),
        body: TabBarView(
          children: [
            _ListingsTab(ref: ref),
            _VehiclesTab(ref: ref),
          ],
        ),
      ),
    );
  }
}

class _ListingsTab extends ConsumerWidget {
  final WidgetRef ref;
  const _ListingsTab({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final async = ref.watch(_myListingsProvider);
    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.sell_outlined,
            title: 'No listings yet',
            message: 'Cars you list for sale will show up here.',
            actionLabel: 'Sell a Car',
            onAction: () => context.push('/post-listing'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: items.length,
          itemBuilder: (context, i) => _ListingRow(listing: items[i]),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 3,
        itemBuilder: (_, __) => const SkeletonRowCard(),
      ),
      error: (e, st) => ErrorState(onRetry: () => ref.invalidate(_myListingsProvider)),
    );
  }
}

class _VehiclesTab extends ConsumerWidget {
  final WidgetRef ref;
  const _VehiclesTab({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final async = ref.watch(_myVehiclesProvider);
    return async.when(
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.car_rental_outlined,
            title: 'No rental vehicles yet',
            message: 'Cars you list for rent will show up here.',
            actionLabel: 'List a Car for Rent',
            onAction: () => context.push('/list-for-rent'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: items.length,
          itemBuilder: (context, i) => _VehicleRow(vehicle: items[i]),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 3,
        itemBuilder: (_, __) => const SkeletonRowCard(),
      ),
      error: (e, st) => ErrorState(onRetry: () => ref.invalidate(_myVehiclesProvider)),
    );
  }
}

class _ListingRow extends StatelessWidget {
  final CarListing listing;
  const _ListingRow({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: listing.photoUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: listing.photoUrls.first, width: 72, height: 60, fit: BoxFit.cover)
                : Container(width: 72, height: 60, color: AppColors.surface),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(pkrFormat.format(listing.price),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          StatusBadge(status: listing.status),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final RentalVehicle vehicle;
  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: vehicle.photoUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: vehicle.photoUrls.first, width: 72, height: 60, fit: BoxFit.cover)
                : Container(width: 72, height: 60, color: AppColors.surface),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${pkrFormat.format(vehicle.dailyRate)}/day',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const StatusBadge(status: 'pending'),
        ],
      ),
    );
  }
}
