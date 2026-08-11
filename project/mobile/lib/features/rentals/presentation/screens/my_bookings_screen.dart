import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../reviews/presentation/review_sheet.dart';
import '../../data/rentals_repository.dart';
import '../../domain/rental_models.dart';
import '../providers/rentals_provider.dart';

const _tabs = ['Upcoming', 'Active', 'Completed', 'Cancelled'];

bool _matchesTab(String status, String tab) {
  switch (tab) {
    case 'Upcoming':
      return status == 'requested' || status == 'confirmed';
    case 'Active':
      return status == 'ongoing';
    case 'Completed':
      return status == 'completed';
    case 'Cancelled':
      return status == 'cancelled';
    default:
      return false;
  }
}

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filtered = bookings.where((b) => _matchesTab(b.status, tab)).toList();
              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No $tab bookings',
                  message: tab == 'Upcoming'
                      ? 'Browse rentals and book your next ride.'
                      : 'Bookings will show up here once they reach this stage.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(myBookingsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _BookingCard(booking: filtered[i], index: i),
                ),
              );
            }).toList(),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: 3,
          itemBuilder: (_, __) => const SkeletonRowCard(),
        ),
        error: (e, st) => ErrorState(onRetry: () => ref.invalidate(myBookingsProvider)),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final Booking booking;
  final int index;
  const _BookingCard({required this.booking, required this.index});

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel booking?',
      message: 'This cannot be undone. The owner will be notified.',
      confirmLabel: 'Cancel Booking',
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(rentalsRepositoryProvider).cancelBooking(booking.id, reason: 'Cancelled by renter');
      ref.invalidate(myBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not cancel booking')));
      }
    }
  }

  Future<void> _review(BuildContext context, WidgetRef ref) async {
    final vehicle = booking.vehicle;
    if (vehicle == null || vehicle.ownerId.isEmpty) return;
    final submitted = await showReviewSheet(context, ref: ref, subjectId: vehicle.ownerId, bookingId: booking.id);
    if (submitted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your review!')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = booking.vehicle;
    final canCancel = booking.status == 'requested' || booking.status == 'confirmed';
    final canReview = booking.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: (v != null && v.photoUrls.isNotEmpty)
                    ? CachedNetworkImage(imageUrl: v.photoUrls.first, width: 76, height: 64, fit: BoxFit.cover)
                    : Container(width: 76, height: 64, color: AppColors.surface, child: const Icon(Icons.directions_car, color: AppColors.textTertiary)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(v?.title ?? 'Vehicle',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        StatusBadge(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shortDateFormat.format(booking.startDate)} → ${shortDateFormat.format(booking.endDate)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(pkrFormat.format(booking.totalPrice),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          if (canCancel || canReview) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canCancel)
                  TextButton(
                    onPressed: () => _cancel(context, ref),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    child: const Text('Cancel'),
                  ),
                if (canReview)
                  OutlinedButton.icon(
                    onPressed: () => _review(context, ref),
                    icon: const Icon(Icons.star_outline_rounded, size: 16),
                    label: const Text('Leave a Review'),
                  ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.06, end: 0);
  }
}
