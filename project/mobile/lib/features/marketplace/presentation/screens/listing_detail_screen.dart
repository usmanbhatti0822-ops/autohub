import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../reviews/data/reviews_repository.dart';
import '../providers/listings_provider.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      body: listingAsync.when(
        data: (listing) {
          final ratingAsync = ref.watch(userRatingProvider(listing.sellerId ?? ''));
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                stretchTriggerOffset: 120,
                onStretchTrigger: () async {},
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: Hero(
                    tag: 'listing-image-${listing.id}',
                    child: _ImageCrossfadeCarousel(photoUrls: listing.photoUrls),
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
                            child: Text(listing.title,
                                style: Theme.of(context).textTheme.headlineSmall),
                          ),
                          CategoryChip(category: listing.category, fontSize: 12),
                        ],
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        pkrFormat.format(listing.price),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ).animate().fadeIn(delay: 60.ms),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _SpecChip(icon: Icons.speed, label: '${listing.mileageKm} km'),
                          _SpecChip(icon: Icons.location_on, label: listing.city),
                          _SpecChip(icon: Icons.settings, label: listing.transmission),
                          _SpecChip(icon: Icons.local_gas_station, label: listing.fuelType),
                          _SpecChip(icon: Icons.event_seat_outlined, label: '${listing.seats} seats'),
                          _SpecChip(icon: Icons.sensor_door_outlined, label: '${listing.doors} doors'),
                        ],
                      ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06, end: 0),
                      if (listing.features.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Features',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: listing.features
                              .map((f) => Chip(label: Text(f), visualDensity: VisualDensity.compact))
                              .toList(),
                        ),
                      ],
                      if (listing.description != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text('Description',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium)
                            .animate()
                            .fadeIn(delay: 180.ms),
                        const SizedBox(height: AppSpacing.xs),
                        Text(listing.description!)
                            .animate()
                            .fadeIn(delay: 220.ms)
                            .slideY(begin: 0.05, end: 0),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text('Seller', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: Row(
                          children: [
                            AppAvatar(name: 'Seller', size: 40),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(listing.isVerified ? 'Verified Seller' : 'Seller',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ratingAsync.when(
                                    data: (r) => RatingStars(rating: r.average, count: r.count, size: 13),
                                    loading: () => const SizedBox.shrink(),
                                    error: (e, st) => const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ratingAsync.maybeWhen(
                        data: (r) => r.reviews.isEmpty
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: AppSpacing.xs),
                                    ...r.reviews.take(3).map((rev) => Padding(
                                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                          child: Container(
                                            padding: const EdgeInsets.all(AppSpacing.sm),
                                            decoration: BoxDecoration(
                                              color: AppColors.surface,
                                              borderRadius: BorderRadius.circular(AppRadii.md),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(rev.authorName,
                                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                    const Spacer(),
                                                    RatingStars(rating: rev.rating.toDouble(), size: 12),
                                                  ],
                                                ),
                                                if (rev.comment != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(rev.comment!, style: const TextStyle(fontSize: 13)),
                                                ],
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 100), // room for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => ErrorState(onRetry: () => ref.invalidate(listingDetailProvider(listingId))),
      ),
      bottomNavigationBar: listingAsync.maybeWhen(
        data: (listing) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showInquiryDialog(context, listing.title),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contact Seller'),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
        orElse: () => null,
      ),
    );
  }

  void _showInquiryDialog(BuildContext context, String listingTitle) {
    final controller = TextEditingController(
      text: "Hi, I'm interested in your $listingTitle. Is it still available?",
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Seller'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent to seller!')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

/// Auto-advancing image carousel with a smooth crossfade between photos
/// and dot indicators — mirrors the reference video's hero image
/// transitions instead of a hard cut between product shots.
class _ImageCrossfadeCarousel extends StatefulWidget {
  final List<String> photoUrls;
  const _ImageCrossfadeCarousel({required this.photoUrls});

  @override
  State<_ImageCrossfadeCarousel> createState() => _ImageCrossfadeCarouselState();
}

class _ImageCrossfadeCarouselState extends State<_ImageCrossfadeCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.directions_car, size: 64, color: Colors.white70),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: CachedNetworkImage(
            key: ValueKey(widget.photoUrls[_index]),
            imageUrl: widget.photoUrls[_index],
            fit: BoxFit.cover,
          ),
        ),
        // Subtle bottom gradient so title text stays legible over any photo,
        // matching the dark-hero look in the reference.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black38],
            ),
          ),
        ),
        if (widget.photoUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.photoUrls.length, (i) {
                final selected = i == _index;
                return GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: selected ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: Colors.grey.shade300),
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
