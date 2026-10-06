import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class StalenessBanner extends StatelessWidget {
  final int secondsSinceSync;
  final VoidCallback onRefresh;

  const StalenessBanner({
    super.key,
    required this.secondsSinceSync,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final warningColor = colors?.error ?? colorScheme.error;

    return Container(
      width: double.infinity,
      color: warningColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: warningColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.liveLocationPaused.tr(args: [secondsSinceSync.toString()]),
              style: textTheme.bodySmall?.copyWith(color: warningColor),
            ),
          ),
          InkWell(
            onTap: onRefresh,
            child: Text(
              AppStrings.retry.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: warningColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}