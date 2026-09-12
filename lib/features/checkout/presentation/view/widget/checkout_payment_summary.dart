import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';

class CheckoutBottomSummarySection extends StatelessWidget {
  final String cartId;
  final AppColors colors;
  final GlobalKey<FormState> giftFormKey;

  const CheckoutBottomSummarySection({
    super.key,
    required this.cartId,
    required this.colors,
    required this.giftFormKey,
  });

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        buildWhen: (prev, curr) =>
        prev.checkoutDetailsResource != curr.checkoutDetailsResource ||
            prev.placeOrderResource != curr.placeOrderResource ||
            prev.selectedAddressId != curr.selectedAddressId ||
            prev.isGift != curr.isGift ||
            prev.selectedPaymentMethod != curr.selectedPaymentMethod,
        builder: (context, checkoutState) {
          final cubit = context.read<CheckoutCubit>();
          final details = checkoutState.checkoutDetailsResource.data;
          final subtotal = details?.subtotal ?? 0.0;
          final deliveryFee = details?.deliveryFee ?? 0.0;
          final total = details?.total ?? 0.0;
          final currency = AppStrings.egyptCurrency.tr();

          return Column(
            children: [
              _buildSummaryRow(
                AppStrings.subTotal.tr(),
                '${subtotal.toStringAsFixed(2)} $currency',
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                AppStrings.deliveryFee.tr(),
                '${deliveryFee.toStringAsFixed(2)} $currency',
              ),
              const Divider(height: 24, thickness: 0.8),
              _buildSummaryRow(
                AppStrings.total.tr(),
                '${total.toStringAsFixed(2)} $currency',
                isTotal: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: checkoutState.placeOrderResource.isLoading
                      ? null
                      : () {
                    if (checkoutState.selectedAddressId == null ||
                        checkoutState.selectedAddressId!.isEmpty) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.selectAddressWarning.tr(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      return;
                    }

                    if (checkoutState.selectedPaymentMethod == null ||
                        checkoutState.selectedPaymentMethod!.isEmpty) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.paymentMethod.tr(),
                            ),
                            backgroundColor:
                            Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      return;
                    }

                    final isNotCash = checkoutState
                        .selectedPaymentMethod
                        ?.toUpperCase() !=
                        'COD';

                    if (checkoutState.isGift && isNotCash) {
                      if (!(giftFormKey.currentState?.validate() ??
                          false)) {
                        return;
                      }
                    }

                    cubit.doEvents(PlaceOrderEvent(cartId));
                  },
                  child: checkoutState.placeOrderResource.isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.white,
                    ),
                  )
                      : Text(
                    AppStrings.placeOrder.tr(),
                    style: TextStyle(color: colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}