import 'package:flutter/material.dart';

import '../../../../../core/app_theme/app_colors.dart';
class DeliveredAddressCard extends StatelessWidget {
  final String title;
  final String detail;
  final Color cardBg;
  final Color cardBorder;

  const DeliveredAddressCard({
    super.key,
    required this.title,
    required this.detail,
    required this.cardBg,
    required this.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors?.textPrimary ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              detail,
              style: textTheme.bodySmall?.copyWith(
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}