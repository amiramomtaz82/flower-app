import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/cart_entity.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({super.key, required this.cart, this.onCheckout});

  final CartEntity cart;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).extension<LightColors>()!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: AppStrings.subTotal.tr(), amount: cart.subtotal),
          const SizedBox(height: 8),
          _SummaryRow(
            label: AppStrings.deliveryFee.tr(),
            amount: cart.deliveryFee,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: colors.surface),
          ),
          _SummaryRow(
            label: AppStrings.total.tr(),
            amount: cart.total,
            isTotal: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCheckout,
            child: Text(AppStrings.checkout.tr()),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final num? amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = isTotal
        ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.bodyMedium?.copyWith(color: colors.darkGrey);

    final amountStyle = isTotal
        ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text('${AppStrings.currency.tr()} ${amount ?? 0}', style: amountStyle),
      ],
    );
  }
}
