import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/app_constants/app_strings.dart';
import '../../../../../core/app_theme/app_colors.dart';
class CostBreakdown extends StatelessWidget {
  final num subTotal;
  final num deliveryFee;
  final num total;
  final String currency;

  const CostBreakdown({
    super.key,
    required this.subTotal,
    required this.deliveryFee,
    required this.total,
    this.currency = 'EGP',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Sub Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.subTotal.tr(),
              style: textTheme.bodyMedium?.copyWith(
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              subTotal.toStringAsFixed(0),
              style: textTheme.bodyMedium?.copyWith(
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Delivery Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.deliveryFee.tr(),
              style: textTheme.bodyMedium?.copyWith(
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              deliveryFee.toStringAsFixed(0),
              style: textTheme.bodyMedium?.copyWith(
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.total.tr(),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors?.textPrimary ?? colorScheme.onSurface,
              ),
            ),
            Text(
              total.toStringAsFixed(0),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors?.textPrimary ?? colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
