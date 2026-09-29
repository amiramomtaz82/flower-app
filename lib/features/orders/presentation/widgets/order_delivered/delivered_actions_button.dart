import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/app_constants/app_strings.dart';

class DeliveredActionsButton extends StatelessWidget {
  final Color primary;
  final VoidCallback? onReorder;
  final VoidCallback? onRate;

  const DeliveredActionsButton({
    super.key,
    required this.primary,
    this.onReorder,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Row(
      children: [
        // Reorder Button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: onReorder ?? () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.reorder.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Rate Button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: onRate ?? () {},
            child: Text(
              AppStrings.rate.tr(),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}