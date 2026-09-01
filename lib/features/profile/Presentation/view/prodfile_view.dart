import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Static placeholder profile. Will be wired to the real user/profile
/// data source once that feature is built.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.surface,
                  child: Icon(Icons.person, size: 40, color: colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Nour', style: textTheme.titleLarge),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_outlined, size: 16, color: colors.darkGrey),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Nour_Mohamed@gmail.com',
                  style: textTheme.bodyMedium?.copyWith(color: colors.darkGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileTile(
            icon: Icons.receipt_long_outlined,
            title: 'My orders',
            colors: colors,
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.location_on_outlined,
            title: 'Saved address',
            colors: colors,
            onTap: () => context.push(AppRoutes.savedAddresses),
          ),
          const Divider(height: 32),
          _ProfileTile(
            icon: Icons.notifications_none_outlined,
            title: 'Notification',
            colors: colors,
            trailing: Switch(
              value: _notificationsEnabled,
              activeThumbColor: colors.primary,
              onChanged: (value) =>
                  setState(() => _notificationsEnabled = value),
            ),
          ),
          const Divider(height: 32),
          _ProfileTile(
            icon: Icons.translate,
            title: 'Language',
            colors: colors,
            trailing: Text(
              'English',
              style: textTheme.bodyMedium?.copyWith(color: colors.primary),
            ),
            onTap: () {},
          ),
          _ProfileTile(
            icon: null,
            title: 'About us',
            colors: colors,
            onTap: () {},
          ),
          _ProfileTile(
            icon: null,
            title: 'Terms & conditions',
            colors: colors,
            onTap: () {},
          ),
          const Divider(height: 32),
          _ProfileTile(
            icon: Icons.logout,
            title: 'Logout',
            colors: colors,
            trailingIcon: Icons.arrow_forward,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'v 6.3.0 - (446)',
              style: textTheme.bodySmall?.copyWith(color: colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.title,
    required this.colors,
    this.icon,
    this.trailing,
    this.trailingIcon,
    this.onTap,
  });

  final String title;
  final AppColors colors;
  final IconData? icon;
  final Widget? trailing;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon == null ? null : Icon(icon, color: colors.textPrimary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing:
          trailing ??
          Icon(trailingIcon ?? Icons.chevron_right, color: colors.darkGrey),
      onTap: onTap,
    );
  }
}
