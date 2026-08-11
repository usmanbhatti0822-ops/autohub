import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/error_state.dart';
import '../providers/rentals_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String bookingId;
  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      body: SafeArea(
        child: bookingAsync.when(
          data: (booking) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const Spacer(),
                SuccessCheck(
                  title: 'Booking Requested!',
                  message: booking.vehicle != null
                      ? '${booking.vehicle!.title} is reserved for ${shortDateFormat.format(booking.startDate)} – ${shortDateFormat.format(booking.endDate)}. The owner will confirm shortly.'
                      : 'The owner will confirm your booking shortly.',
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Column(
                    children: [
                      _row('Booking ID', '#${booking.id.substring(0, 8).toUpperCase()}'),
                      _row('Total', pkrFormat.format(booking.totalPrice)),
                      _row('Status', booking.status[0].toUpperCase() + booking.status.substring(1)),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/my-bookings'),
                    child: const Text('View My Bookings'),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => ErrorState(onRetry: () => ref.invalidate(bookingDetailProvider(bookingId))),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
