import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../providers/auth_provider.dart';

enum _Strength { empty, weak, fair, strong }

_Strength _passwordStrength(String v) {
  if (v.isEmpty) return _Strength.empty;
  var score = 0;
  if (v.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(v)) score++;
  if (RegExp(r'[0-9]').hasMatch(v)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score++;
  if (score <= 1) return _Strength.weak;
  if (score <= 2) return _Strength.fair;
  return _Strength.strong;
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _loading = false;
  String? _error;
  _Strength _strength = _Strength.empty;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      setState(() => _error = 'Please accept the Terms & Conditions to continue.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).register(
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: '+92${_phone.text.trim()}',
            password: _password.text,
          );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      final msg = e.toString().contains('already exists')
          ? 'An account with this email or phone already exists.'
          : 'Could not create your account. Please try again.';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _strengthColor(_Strength s) => switch (s) {
        _Strength.empty => AppColors.outline,
        _Strength.weak => AppColors.danger,
        _Strength.fair => AppColors.warning,
        _Strength.strong => AppColors.success,
      };

  String _strengthLabel(_Strength s) => switch (s) {
        _Strength.empty => '',
        _Strength.weak => 'Weak password',
        _Strength.fair => 'Fair password',
        _Strength.strong => 'Strong password',
      };

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
                Text('Create your account', style: Theme.of(context).textTheme.headlineSmall)
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppSpacing.xs),
                Text('Join AutoHub to buy, sell, and rent cars.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    counterText: '',
                    prefixIcon: Icon(Icons.smartphone_rounded),
                    prefixText: '+92 ',
                  ),
                  validator: (v) => (v == null || !RegExp(r'^3[0-9]{9}$').hasMatch(v))
                      ? 'Enter a valid number, e.g. 3001234567'
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  onChanged: (v) => setState(() => _strength = _passwordStrength(v)),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                if (_strength != _Strength.empty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          child: LinearProgressIndicator(
                            value: switch (_strength) {
                              _Strength.weak => 0.33,
                              _Strength.fair => 0.66,
                              _Strength.strong => 1,
                              _Strength.empty => 0,
                            },
                            minHeight: 5,
                            backgroundColor: AppColors.outline,
                            color: _strengthColor(_strength),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_strengthLabel(_strength),
                          style: TextStyle(fontSize: 11, color: _strengthColor(_strength), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) => (v != _password.text) ? 'Passwords do not match' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'I agree to the Terms & Conditions and Privacy Policy',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  const SizedBox(height: AppSpacing.xs),
                ],
                const SizedBox(height: AppSpacing.sm),
                LoadingButton(loading: _loading, onPressed: _submit, child: const Text('Create Account')),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => context.pushReplacement('/login'),
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
