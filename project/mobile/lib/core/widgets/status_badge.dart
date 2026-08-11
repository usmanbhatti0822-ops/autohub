import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small pill used for booking/listing statuses. Colors map to the same
/// status vocabulary the backend uses so a glance at the color is enough.
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  static Color _color(String status) {
    switch (status) {
      case 'confirmed':
      case 'approved':
        return AppColors.success;
      case 'ongoing':
        return AppColors.primary;
      case 'cancelled':
      case 'rejected':
        return AppColors.danger;
      case 'completed':
      case 'sold':
        return AppColors.textSecondary;
      default: // requested / pending
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
