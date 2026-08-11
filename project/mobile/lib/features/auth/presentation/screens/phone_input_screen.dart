import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../providers/auth_provider.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final digits = _controller.text.trim();
    if (digits.length != 10 || !RegExp(r'^3[0-9]{9}$').hasMatch(digits)) {
      setState(() => _error = 'Enter a valid 10-digit number starting with 3 (e.g. 3001234567)');
      return;
    }
    final phone = '+92$digits';
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final devCode = await ref.read(authProvider.notifier).requestOtp(phone);
      if (!mounted) return;
      context.push('/otp', extra: {'phone': phone, 'devCode': devCode});
    } catch (e) {
      setState(() => _error = 'Could not send code. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car_filled_rounded,
                      size: 56, color: AppColors.primary)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.7, 0.7)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "What's your number?",
                style: Theme.of(context).textTheme.headlineSmall,
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "We'll text you a one-time code — no password needed.",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 190.ms),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: const Text('🇵🇰 +92', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '3XXXXXXXXX',
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: AppSpacing.lg),
              LoadingButton(
                loading: _loading,
                onPressed: _submit,
                child: const Text('Send Code'),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Demo tip: use 3000000000 for the demo account',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textTertiary),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
