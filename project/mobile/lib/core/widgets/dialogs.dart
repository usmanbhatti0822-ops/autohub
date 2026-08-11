import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Standard yes/no confirmation dialog (cancel booking, logout, delete listing...).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? AppColors.danger : AppColors.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Full-screen-ish success moment: animated check + message, auto styled.
/// Used after booking confirmation, review submission, etc.
class SuccessCheck extends StatelessWidget {
  final String title;
  final String message;
  const SuccessCheck({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(color: AppColors.successSoft, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: AppColors.success, size: 52),
        )
            .animate()
            .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 700.ms)
            .fadeIn(duration: 200.ms),
        const SizedBox(height: AppSpacing.lg),
        Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center)
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 280.ms),
      ],
    );
  }
}
