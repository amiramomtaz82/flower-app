import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';

import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_item_entity.dart';
import '../../domain/oredr_details_entity.dart';

class OrderDeliveredView extends StatelessWidget {
  final OrderTrackingEntity? trackingData;
  final OrderDetailsEntity? orderDetails;
  final VoidCallback? onReorder;
  final VoidCallback? onRate;

  const OrderDeliveredView({
    super.key,
    this.trackingData,
    this.orderDetails,
    this.onReorder,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final primary = colors?.primary ?? colorScheme.primary;
    final successColor = colors?.success ?? const Color(0xff0CB359);
    final cardBorder = (colors?.grey ?? Colors.grey).withOpacity(0.2);
    final cardBg = colors?.white ?? colorScheme.surface;

    // Loading state while order details are being fetched
    if (orderDetails == null) {
      return Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    final details = orderDetails!;
    final resolvedAddress = details.addressDetail.isNotEmpty
        ? details.addressDetail
        : (trackingData?.userAddress.addressLine ?? '269VP+Q2 - Sheikh Zayed');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Delivery Status Header
                    _DeliveryStatusHeader(
                      userName: details.customerName,
                      successColor: successColor,
                    ),
                    const SizedBox(height: 20),

                    // 2. Delivery Address Card
                    _AddressCard(
                      title: details.addressTitle,
                      detail: resolvedAddress,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                    const SizedBox(height: 12),

                    // 3. Payment Method Card (from OrderDetailsEntity)
                    _PaymentCard(
                      amount: '${details.currency} ${details.total.toStringAsFixed(0)}',
                      paymentMethod: details.paymentMethod,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                    ),
                    const SizedBox(height: 16),

                    // 4. Order Items Card (List of OrderItemEntity)
                    _OrderItemsCard(
                      items: details.items,
                      currency: details.currency,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      primary: primary,
                    ),
                    const SizedBox(height: 20),

                    // 5. Cost Breakdown
                    _CostBreakdown(
                      subTotal: details.subTotal,
                      deliveryFee: details.deliveryFee,
                      total: details.total,
                      currency: details.currency,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 6. Bottom Action Buttons (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _BottomActionButtons(
                primary: primary,
                onReorder: onReorder,
                onRate: onRate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryStatusHeader extends StatelessWidget {
  final String userName;
  final Color successColor;

  const _DeliveryStatusHeader({
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

class _AddressCard extends StatelessWidget {
  final String title;
  final String detail;
  final Color cardBg;
  final Color cardBorder;

  const _AddressCard({
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

class _PaymentCard extends StatelessWidget {
  final String amount;
  final String paymentMethod;
  final Color cardBg;
  final Color cardBorder;

  const _PaymentCard({
    required this.amount,
    required this.paymentMethod,
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
                Icons.payments_outlined,
                size: 20,
                color: colors?.secondary ?? colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                amount,
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
              paymentMethod,
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

class _OrderItemsCard extends StatelessWidget {
  final List<OrderItemEntity> items;
  final String currency;
  final Color cardBg;
  final Color cardBorder;
  final Color primary;

  const _OrderItemsCard({
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
                      color: primary.withOpacity(0.06),
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

class _CostBreakdown extends StatelessWidget {
  final num subTotal;
  final num deliveryFee;
  final num total;
  final String currency;

  const _CostBreakdown({
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

class _BottomActionButtons extends StatelessWidget {
  final Color primary;
  final VoidCallback? onReorder;
  final VoidCallback? onRate;

  const _BottomActionButtons({
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