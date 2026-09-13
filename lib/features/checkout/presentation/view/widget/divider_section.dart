
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class CheckoutSectionDivider extends StatelessWidget {
  const CheckoutSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final surfaceColor = colors?.surface ?? Theme.of(context).colorScheme.surfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: 25,
      width: double.infinity,
      color: surfaceColor,
    );
  }
}