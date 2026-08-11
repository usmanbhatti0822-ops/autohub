import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/wallet_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final balanceAsync = ref.watch(walletBalanceProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              children: [
                AppAvatar(imageUrl: user.avatarUrl, name: user.displayName, size: 60),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(user.phone,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.verificationLevel == 'id_verified'
                                  ? Icons.verified_rounded
                                  : Icons.shield_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user.verificationLevel == 'id_verified'
                                  ? 'ID Verified'
                                  : user.phoneVerified
                                      ? 'Phone Verified'
                                      : 'Unverified',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.08, end: 0),
          if (!user.hasCompleteProfile) ...[
            const SizedBox(height: AppSpacing.sm),
            _Banner(
              icon: Icons.info_outline_rounded,
              text: 'Complete your profile to build trust with buyers and renters.',
              onTap: () => context.push('/profile/edit'),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          balanceAsync.when(
            data: (balance) => _WalletCard(balance: balance),
            loading: () => const _WalletCard(balance: null),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MenuTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            onTap: () => context.push('/profile/edit'),
          ),
          _MenuTile(
            icon: Icons.directions_car_outlined,
            label: 'My Listings & Vehicles',
            onTap: () => context.push('/my-listings'),
          ),
          _MenuTile(
            icon: Icons.sell_outlined,
            label: 'Sell a Car',
            onTap: () => context.push('/post-listing'),
          ),
          _MenuTile(
            icon: Icons.car_rental_outlined,
            label: 'List a Car for Rent',
            onTap: () => context.push('/list-for-rent'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          SwitchListTile(
            value: notificationsEnabled,
            onChanged: (v) => ref.read(notificationsEnabledProvider.notifier).toggle(v),
            secondary: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            title: const Text('Push notifications'),
            contentPadding: EdgeInsets.zero,
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & About',
            onTap: () => _showAbout(context),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            danger: true,
            onTap: () async {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Log out?',
                message: "You'll need to sign in again to continue.",
                confirmLabel: 'Log Out',
                destructive: true,
              );
              if (confirmed) await ref.read(authProvider.notifier).logout();
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AutoHub'),
        content: const Text(
          'AutoHub is a portfolio/demo car marketplace and rental platform. '
          'All payments and SMS are simulated for demonstration purposes — '
          'see the README for details on running your own instance.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _Banner({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: const TextStyle(color: AppColors.accent, fontSize: 13))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double? balance;
  const _WalletCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.successSoft, shape: BoxShape.circle),
            child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet balance', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(
                  balance == null ? '—' : pkrFormat.format(balance),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: danger ? AppColors.danger : AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
