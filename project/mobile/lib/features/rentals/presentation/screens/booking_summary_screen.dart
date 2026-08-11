import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../payments/data/payments_repository.dart';
import '../../data/rentals_repository.dart';
import '../../domain/rental_models.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final RentalVehicle vehicle;
  final DateTimeRange range;
  final bool withDriver;

  const BookingSummaryScreen({
    super.key,
    required this.vehicle,
    required this.range,
    required this.withDriver,
  });

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  PaymentMethod _method = PaymentMethod.cashOnPickup;
  bool _submitting = false;
  String? _error;

  int get _days => widget.range.end.difference(widget.range.start).inDays.clamp(1, 999);
  double get _subtotal => _days * widget.vehicle.dailyRate;

  Future<void> _confirm() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final booking = await ref.read(rentalsRepositoryProvider).createBooking(
            vehicleId: widget.vehicle.id,
            startDate: widget.range.start,
            endDate: widget.range.end,
            withDriver: widget.withDriver,
          );

      final orderId = await ref.read(paymentsRepositoryProvider).initiate(
            amount: _subtotal,
            method: _method,
            relatedBookingId: booking.id,
          );
      if (_method == PaymentMethod.mockCard) {
        await ref.read(paymentsRepositoryProvider).devSettle(orderId, success: true);
      }

      if (!mounted) return;
      context.go('/booking-confirmation/${booking.id}');
    } catch (e) {
      final msg = e.toString().contains('not available')
          ? 'Sorry, this vehicle just became unavailable for those dates.'
          : 'Could not complete your booking. Please try again.';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Summary')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.vehicle.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      _row(Icons.location_on_outlined, widget.vehicle.pickupLocation),
                      _row(Icons.date_range_outlined,
                          '${monthDayFormat.format(widget.range.start)} → ${monthDayFormat.format(widget.range.end)} ($_days day${_days > 1 ? 's' : ''})'),
                      if (widget.withDriver) _row(Icons.person_outline_rounded, 'With driver'),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.06, end: 0),
                const SizedBox(height: AppSpacing.md),
                _PriceBreakdown(
                  days: _days,
                  dailyRate: widget.vehicle.dailyRate,
                  securityDeposit: widget.vehicle.securityDeposit,
                ).animate().fadeIn(delay: 80.ms),
                const SizedBox(height: AppSpacing.md),
                Text('Payment method', style: Theme.of(context).textTheme.titleMedium)
                    .animate()
                    .fadeIn(delay: 120.ms),
                const SizedBox(height: AppSpacing.xs),
                _PaymentOption(
                  icon: Icons.payments_outlined,
                  title: 'Cash on Pickup',
                  subtitle: 'Pay the owner in person when you collect the car',
                  selected: _method == PaymentMethod.cashOnPickup,
                  onTap: () => setState(() => _method = PaymentMethod.cashOnPickup),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PaymentOption(
                  icon: Icons.credit_card_rounded,
                  title: 'Pay by Card (Demo)',
                  subtitle: 'Simulated instant payment — no real card is charged',
                  selected: _method == PaymentMethod.mockCard,
                  onTap: () => setState(() => _method = PaymentMethod.mockCard),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: LoadingButton(
                loading: _submitting,
                onPressed: _confirm,
                child: Text('Confirm & ${_method == PaymentMethod.mockCard ? 'Pay' : 'Book'} · ${pkrFormat.format(_subtotal)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          ],
        ),
      );
}

class _PriceBreakdown extends StatelessWidget {
  final int days;
  final double dailyRate;
  final double securityDeposit;
  const _PriceBreakdown({required this.days, required this.dailyRate, required this.securityDeposit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          _line('${pkrFormat.format(dailyRate)} × $days day${days > 1 ? 's' : ''}', pkrFormat.format(dailyRate * days)),
          if (securityDeposit > 0) ...[
            const SizedBox(height: 8),
            _line('Security deposit (refundable)', pkrFormat.format(securityDeposit), muted: true),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
          _line('Total due now', pkrFormat.format(dailyRate * days), bold: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false, bool muted = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      fontSize: bold ? 16 : 14,
      color: muted ? AppColors.textSecondary : AppColors.textPrimary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
