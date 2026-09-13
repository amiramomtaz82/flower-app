import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';

class CheckoutPaymentSection extends StatelessWidget {
  const CheckoutPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final colors = Theme.of(context).extension<AppColors>();
    final primaryColor = colors?.primary ?? Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.paymentMethod,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          BlocBuilder<CheckoutCubit, CheckoutState>(
            buildWhen: (prev, curr) =>
            prev.paymentMethod != curr.paymentMethod ||
                prev.checkoutDetailsResource != curr.checkoutDetailsResource,
            builder: (context, state) {
              final checkoutResource = state.checkoutDetailsResource;

              // 1. Loading state
              if (checkoutResource.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              // 2. Error state
              if (checkoutResource.isError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    checkoutResource.errorMessage ?? AppStrings.somethingWentWrong,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              final paymentMethods = checkoutResource.data?.paymentMethods ?? [];

              // 3. Empty state: explicitly inform the user
              if (paymentMethods.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    AppStrings.noPaymentMethodsAvailable, // Or "No payment methods available at the moment."
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              // 4. Data state
              return Column(
                children: paymentMethods.map((method) {
                  final methodValue = method.toString();

                  return InkWell(
                    onTap: () => cubit.doEvents(SelectPaymentMethodEvent(methodValue)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            methodValue,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Radio<String>(
                            value: methodValue,
                            groupValue: state.paymentMethod?.toString(),
                            activeColor: primaryColor,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (val) {
                              if (val != null) {
                                cubit.doEvents(SelectPaymentMethodEvent(val));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}