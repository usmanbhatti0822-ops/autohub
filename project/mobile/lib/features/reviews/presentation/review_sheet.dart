import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/rating_stars.dart';
import '../data/reviews_repository.dart';

/// Bottom sheet for leaving a rating + comment on a completed booking's
/// vehicle owner. Returns true if a review was submitted.
Future<bool?> showReviewSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String subjectId,
  required String bookingId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _ReviewSheetBody(ref: ref, subjectId: subjectId, bookingId: bookingId),
  );
}

class _ReviewSheetBody extends StatefulWidget {
  final WidgetRef ref;
  final String subjectId;
  final String bookingId;
  const _ReviewSheetBody({required this.ref, required this.subjectId, required this.bookingId});

  @override
  State<_ReviewSheetBody> createState() => _ReviewSheetBodyState();
}

class _ReviewSheetBodyState extends State<_ReviewSheetBody> {
  int _rating = 0;
  final _comment = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Please select a star rating');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.ref.read(reviewsRepositoryProvider).create(
            subjectId: widget.subjectId,
            type: 'renter_to_owner',
            rating: _rating,
            comment: _comment.text.trim(),
            relatedBookingId: widget.bookingId,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = 'Could not submit your review. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Rate your experience', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Center(child: RatingInput(value: _rating, onChanged: (v) => setState(() => _rating = v))),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Share a few words (optional)',
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
          const SizedBox(height: AppSpacing.md),
          LoadingButton(loading: _submitting, onPressed: _submit, child: const Text('Submit Review')),
        ],
      ),
    );
  }
}
