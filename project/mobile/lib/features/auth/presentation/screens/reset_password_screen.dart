import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/otp_box_input.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String? devCode;

  const ResetPasswordScreen({super.key, required this.email, this.devCode});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  String _code = '';
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_code.length != 4) {
      setState(() => _error = 'Enter the 4-digit reset code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: widget.email,
            code: _code,
            newPassword: _newPassword.text,
          );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = 'Invalid or expired reset code.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset your password', style: Theme.of(context).textTheme.headlineSmall)
                    .animate()
                    .fadeIn(),
                const SizedBox(height: AppSpacing.xs),
                Text.rich(
                  TextSpan(
                    text: 'Enter the code sent to ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                          text: widget.email,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                const SizedBox(height: AppSpacing.lg),
                OtpBoxInput(
                  length: 4,
                  initialValue: widget.devCode,
                  onChanged: (v) => setState(() => _code = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _newPassword,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (v) => (v != _newPassword.text) ? 'Passwords do not match' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: AppSpacing.lg),
                LoadingButton(loading: _loading, onPressed: _submit, child: const Text('Reset Password')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
