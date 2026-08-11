import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final devCode = await ref.read(authProvider.notifier).forgotPassword(_email.text.trim());
      if (!mounted) return;
      context.push('/reset-password', extra: {'email': _email.text.trim(), 'devCode': devCode});
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset_rounded, size: 52, color: AppColors.primary)
                    .animate()
                    .fadeIn()
                    .scale(begin: const Offset(0.7, 0.7)),
                const SizedBox(height: AppSpacing.lg),
                Text('Forgot your password?', style: Theme.of(context).textTheme.headlineSmall)
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "Enter your email and we'll send you a reset code.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  onFieldSubmitted: (_) => _submit(),
                ).animate().fadeIn(delay: 150.ms),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: AppSpacing.lg),
                LoadingButton(loading: _loading, onPressed: _submit, child: const Text('Send Reset Code'))
                    .animate()
                    .fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
