import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/app_constants/app_strings.dart';
import '../../../../../core/app_theme/app_colors.dart';

class DeliveryStatusHeader extends StatelessWidget {
  final String userName;
  final Color successColor;

  const DeliveryStatusHeader({
    super.key,
    required this.userName,
    required this.successColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Green Checkmark Badge
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: successColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 10),

        // "Order delivered" title
        Text(
          AppStrings.orderDelivered.tr(),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors?.textPrimary ?? colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle: "Enjoy your order Nour!"
        Text(
          '${AppStrings.enjoyYourOrder.tr()} $userName!',
          style:textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors?.textPrimary ,
          ),
        ),
        const SizedBox(height: 14),

        // 4 Segmented Green Dashes
        Row(
          children: List.generate(
            4,
                (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                height: 3.5,
                decoration: BoxDecoration(
                  color: successColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}