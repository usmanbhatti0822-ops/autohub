import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../domain/car_listing.dart';

/// Wide horizontal-scroll card for the Home screen's "Featured Cars" rail —
/// visually distinct from the grid [ListingCard] so featured items read as
/// a curated highlight, not just more of the same grid.
class FeaturedCard extends StatelessWidget {
  final CarListing listing;
  final VoidCallback onTap;

  const FeaturedCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'listing-image-${listing.id}',
                    child: listing.photoUrls.isNotEmpty
                        ? CachedNetworkImage(imageUrl: listing.photoUrls.first, fit: BoxFit.cover)
                        : Container(color: AppColors.surface),
                  ),
                  Positioned(top: 8, left: 8, child: CategoryChip(category: listing.category)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 13, color: AppColors.success),
                          SizedBox(width: 3),
                          Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(pkrFormat.format(listing.price),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 2),
                      Text(listing.city, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.06, end: 0);
  }
}
