import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/otp_box_input.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String? devCode;

  const OtpScreen({super.key, required this.phone, this.devCode});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _boxKey = GlobalKey<OtpBoxInputState>();
  String _code = '';
  bool _loading = false;
  bool _resending = false;
  bool _verified = false;
  String? _error;
  Timer? _timer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    if (widget.devCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _boxKey.currentState?.setValue(widget.devCode!);
      });
    }
  }

  void _startCountdown() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final devCode = await ref.read(authProvider.notifier).requestOtp(widget.phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent')),
      );
      _boxKey.currentState?.clear();
      _startCountdown();
      if (devCode != null) _boxKey.currentState?.setValue(devCode);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not resend code')));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _submit() async {
    if (_code.length < 4) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).verifyOtp(widget.phone, _code);
      if (!mounted) return;
      setState(() => _verified = true);
      await Future.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = 'Invalid or expired code. Please try again.');
      _boxKey.currentState?.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verified) {
      return Scaffold(
        body: Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: AppColors.successSoft, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 44),
          )
              .animate()
              .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 600.ms),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verify your number',
                    style: Theme.of(context).textTheme.headlineSmall)
                .animate()
                .fadeIn()
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.xs),
            Text.rich(
              TextSpan(
                text: 'Enter the 4-digit code sent to ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: widget.phone,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            if (widget.devCode != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text('Demo mode — code is ${widget.devCode}',
                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            OtpBoxInput(
              key: _boxKey,
              length: 4,
              initialValue: widget.devCode,
              hasError: _error != null,
              onChanged: (v) => setState(() {
                _code = v;
                _error = null;
              }),
              onCompleted: (_) => _submit(),
            ).animate().fadeIn(delay: 150.ms),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(
              loading: _loading,
              onPressed: _code.length == 4 ? _submit : null,
              child: const Text('Verify & Continue'),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: _secondsLeft > 0
                  ? Text(
                      'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    )
                  : TextButton(
                      onPressed: _resending ? null : _resend,
                      child: _resending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Resend code'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
