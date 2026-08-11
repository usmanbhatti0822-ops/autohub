import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../domain/car_listing.dart';

class ListingCard extends StatelessWidget {
  final CarListing listing;
  final VoidCallback onTap;
  final int animationIndex;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'listing-image-${listing.id}',
                    child: listing.photoUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: listing.photoUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.surface),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surface,
                              child: const Icon(Icons.directions_car,
                                  size: 40, color: AppColors.textTertiary),
                            ),
                          )
                        : Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.directions_car,
                                size: 40, color: AppColors.textTertiary),
                          ),
                  ),
                  Positioned(top: 6, left: 6, child: CategoryChip(category: listing.category)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (listing.isVerified)
                        const Icon(Icons.verified_rounded,
                            size: 15, color: AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pkrFormat.format(listing.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 2),
                      Text('${listing.mileageKm}km', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(listing.city,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (40 * animationIndex).ms, duration: 300.ms)
        .slideY(begin: 0.08, end: 0);
  }
}
