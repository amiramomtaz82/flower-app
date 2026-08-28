import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class DeliverToRow extends StatelessWidget {
  const DeliverToRow({super.key, required this.address, this.onTap});

  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).extension<LightColors>()!;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 18, color: colors.textPrimary),
          const SizedBox(width: 4),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Deliver to  ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: colors.primary),
        ],
      ),
    );
  }
}
