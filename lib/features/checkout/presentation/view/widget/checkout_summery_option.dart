import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';

class CheckoutSummarySection extends StatelessWidget {
  final String cartId;
  final GlobalKey<FormState> giftFormKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const CheckoutSummarySection({
    super.key,
    required this.cartId,
    required this.giftFormKey,
    required this.nameController,
    required this.phoneController,
  });

  bool _isCash(String? method) {
    if (method == null) return false;
    final normalized = method.trim().toLowerCase();
    return normalized == 'cash' || normalized == 'cod' || normalized.contains('cash');
  }

  void _onPlaceOrder(BuildContext context, CheckoutState state) {
    final cubit = context.read<CheckoutCubit>();

    if (state.selectedAddressId == null || state.selectedAddressId!.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(AppStrings.selectAddressWarning),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (state.paymentMethod == null || state.paymentMethod!.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(AppStrings.selectPaymentMethodWarning),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final isCash = _isCash(state.paymentMethod);
    if (state.isGift && !isCash) {
      if (!(giftFormKey.currentState?.validate() ?? false)) return;
      cubit.doEvents(
        UpdateGiftDetailsEvent(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
        ),
      );
    }

    cubit.doEvents(PlaceOrderEvent(cartId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final primaryColor = colors?.primary ?? Theme.of(context).primaryColor;

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen: (prev, curr) =>
      prev.checkoutDetailsResource != curr.checkoutDetailsResource ||
          prev.placeOrderResource.isLoading != curr.placeOrderResource.isLoading,
      builder: (context, state) {
        final details = state.checkoutDetailsResource.data;
        final subtotal = details?.subtotal ?? 0.0;
        final deliveryFee = details?.deliveryFee ?? 0.0;
        final total = details?.total ?? 0.0;
        final isLoading = state.placeOrderResource.isLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _SummaryRow(label: AppStrings.subTotal.tr(), amount: '${subtotal.toStringAsFixed(2)}\$'),
              const SizedBox(height: 8),
              _SummaryRow(label: AppStrings.deliveryFee.tr(), amount: '${deliveryFee.toStringAsFixed(2)}\$'),
              const Divider(height: 24, thickness: 0.8),
              _SummaryRow(label: AppStrings.total.tr(), amount: '${total.toStringAsFixed(2)}\$', isTotal: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: isLoading ? null : () => _onPlaceOrder(context, state),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(AppStrings.placeOrder.tr(), style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.amount, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: Colors.black,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}