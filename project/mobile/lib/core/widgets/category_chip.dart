import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Colored tag showing a vehicle's category (SUV, Sedan, Luxury, ...).
class CategoryChip extends StatelessWidget {
  final String category;
  final double fontSize;

  const CategoryChip({super.key, required this.category, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);
    final label = category.isEmpty
        ? 'Car'
        : category[0].toUpperCase() + category.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: fontSize),
      ),
    );
  }
}

/// Selectable filter chip for category pickers (home quick-filters, search sheet).
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.hero : null,
          color: selected ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: selected ? Colors.transparent : AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
