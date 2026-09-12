import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';


class CheckoutPaymentMethodSection extends StatelessWidget {
  final AppColors colors;

  const CheckoutPaymentMethodSection({
    super.key,
    required this.colors,
  });

  String _formatMethodTitle(String method) {
    switch (method.toUpperCase()) {
      case 'COD':
        return AppStrings.cashOnDelivery.tr();
      case 'CARD':
        return AppStrings.creditCard.tr();
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.paymentMethod.tr(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          BlocBuilder<CheckoutCubit, CheckoutState>(
            buildWhen: (prev, curr) =>
            prev.checkoutDetailsResource != curr.checkoutDetailsResource ||
                prev.selectedPaymentMethod != curr.selectedPaymentMethod,
            builder: (context, state) {
              final cubit = context.read<CheckoutCubit>();
              final paymentMethods =
                  state.checkoutDetailsResource.data?.paymentMethods ?? [];

              if (paymentMethods.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    AppStrings.noSavedAddresses.tr(), // or localized "No payment methods available"
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final option = paymentMethods[index];
                  final isSelected = state.selectedPaymentMethod == option.method;

                  return InkWell(
                    onTap: () {
                      final gateway = (option.method.toUpperCase() == 'CARD' &&
                          option.gateways.isNotEmpty)
                          ? option.gateways.first
                          : null;

                      cubit.doEvents(
                        SelectPaymentMethodEvent(
                          method: option.method,
                          gateway: gateway,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatMethodTitle(option.method),
                            style: const TextStyle(fontSize: 14),
                          ),
                          Radio<String>(
                            value: option.method,
                            groupValue: state.selectedPaymentMethod,
                            activeColor: colors.primary,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              if (val != null) {
                                final gateway = (val.toUpperCase() == 'CARD' &&
                                    option.gateways.isNotEmpty)
                                    ? option.gateways.first
                                    : null;

                                cubit.doEvents(
                                  SelectPaymentMethodEvent(
                                    method: val,
                                    gateway: gateway,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}