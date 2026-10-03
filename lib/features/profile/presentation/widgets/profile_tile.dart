import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.title,
    this.colors,
    this.icon,
    this.trailing,
    this.trailingIcon,
    this.onTap,
  });

  final String title;
  final LightColors? colors;
  final IconData? icon;
  final Widget? trailing;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColors =
        colors ?? Theme.of(context).extension<LightColors>() ?? LightColors();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon == null
          ? null
          : Icon(icon, color: effectiveColors.textPrimary),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing:
          trailing ??
          Icon(
            trailingIcon ?? Icons.chevron_right,
            color: effectiveColors.darkGrey,
          ),
      onTap: onTap,
    );
  }
}
