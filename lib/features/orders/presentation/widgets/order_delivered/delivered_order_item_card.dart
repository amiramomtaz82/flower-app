import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/app_constants/app_assets.dart';
import '../../../../../core/app_constants/app_strings.dart';
import '../../../../../core/app_theme/app_colors.dart';
import '../../../domain/entities/order_item_entity.dart';

class DeliveredOrderItemsCard extends StatelessWidget {
  final List<OrderItemEntity> items;
  final String currency;
  final Color cardBg;
  final Color cardBorder;
  final Color primary;

  const DeliveredOrderItemsCard({
    super.key,
    required this.items,
    required this.currency,
    required this.cardBg,
    required this.cardBorder,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Shopping Cart Icon + items count
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 20,
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '${items.length} ${AppStrings.cart.tr()}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors?.textPrimary ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list from OrderItemEntity
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  // Product Thumbnail Box
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(item.imageUrl!, fit: BoxFit.contain)
                        : Image.asset(AppAssets.flowerImage, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 12),

                  // Item Title & Subtitle (description)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors?.textPrimary ?? colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors?.secondary ?? colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    '$currency ${item.price.toStringAsFixed(0)}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors?.textPrimary ?? colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
