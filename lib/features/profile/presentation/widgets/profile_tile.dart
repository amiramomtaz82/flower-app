import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
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
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ??
          Icon(trailingIcon ?? Icons.chevron_right, color: colors.darkGrey),
      onTap: onTap,
    );
  }
}
