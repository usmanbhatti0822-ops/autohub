import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../providers/auth_provider.dart';

const _demoPhone = '+923000000000';
const _demoOtp = '1234';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _demoLoading = false;
  String? _error;

  Future<void> _continueWithDemo() async {
    setState(() {
      _demoLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).requestOtp(_demoPhone);
      await ref.read(authProvider.notifier).verifyOtp(_demoPhone, _demoOtp);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = 'Demo login failed. Is the backend running?');
    } finally {
      if (mounted) setState(() => _demoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        child: const Icon(Icons.directions_car_filled_rounded,
                            size: 34, color: Colors.white),
                      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.7, 0.7)),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'AutoHub',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 36,
                            ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Buy, sell, or rent a car —\nall in one place across Pakistan.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/phone'),
                      icon: const Icon(Icons.smartphone_rounded, size: 18),
                      label: const Text('Continue with Phone'),
                    ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.15, end: 0),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/login'),
                      icon: const Icon(Icons.mail_outline_rounded, size: 18),
                      label: const Text('Log in with Email'),
                    ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.15, end: 0),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                            style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.push('/signup'),
                          child: const Text('Sign up'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: AppSpacing.sm),
                    Row(children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: AppColors.textTertiary)),
                      ),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    LoadingButton(
                      loading: _demoLoading,
                      outlined: true,
                      onPressed: _continueWithDemo,
                      icon: Icons.bolt_rounded,
                      child: const Text('Try the Demo Account'),
                    ).animate().fadeIn(delay: 340.ms),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                    ],
                  ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
