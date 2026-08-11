import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Compact star-rating display (read-only) used on cards and detail screens.
class RatingStars extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;

  const RatingStars({super.key, required this.rating, this.count, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.star, size: size),
        const SizedBox(width: 3),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : 'New',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: size * 0.9, color: AppColors.textPrimary),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 3),
          Text('($count)',
              style: TextStyle(fontSize: size * 0.8, color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}

/// Interactive star picker used on the "Leave a review" sheet.
class RatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const RatingInput({super.key, required this.value, required this.onChanged, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.star,
            size: size,
          ),
        );
      }),
    );
  }
}
