import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = LightColors();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onBack ?? () => context.pop(),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.darkGrey),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
