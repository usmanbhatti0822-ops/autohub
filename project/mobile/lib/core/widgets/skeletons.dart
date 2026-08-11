import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Wraps [child] in a consistent shimmer sweep. All skeleton widgets below
/// build on this so loading states look like one system, not ad-hoc grey boxes.
class ShimmerWrap extends StatelessWidget {
  final Widget child;
  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEDEEF2),
      highlightColor: const Color(0xFFF8F9FB),
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = AppRadii.xs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Matches the visual footprint of [ListingCard] while data loads.
class SkeletonListingCard extends StatelessWidget {
  const SkeletonListingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 110, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 70, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 130, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches a horizontal row-card layout (rental browse list, my bookings, etc).
class SkeletonRowCard extends StatelessWidget {
  const SkeletonRowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 70,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.sm)),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 90, height: 12),
                  SizedBox(height: 8),
                  SkeletonBox(width: 110, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
