import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_state.dart';



class CheckoutDeliveryTimeSection extends StatelessWidget {
  final AppColors colors;

  const CheckoutDeliveryTimeSection({
    super.key,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.deliveryTime.tr(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.watch_later_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                AppStrings.instant.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 6),
              BlocBuilder<CheckoutCubit, CheckoutState>(
                buildWhen: (prev, curr) =>
                prev.estimateDeliveryResource != curr.estimateDeliveryResource ||
                    prev.checkoutDetailsResource != curr.checkoutDetailsResource,
                builder: (context, state) {
                  final isEstimateLoading = state.estimateDeliveryResource.isLoading;
                  final isDetailsLoading = state.checkoutDetailsResource.isLoading;

                  if (isEstimateLoading || isDetailsLoading) {
                    return SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    );
                  }

                  final estimatedTime =
                      state.estimateDeliveryResource.data?.estimatedDeliveryAt ??
                          state.checkoutDetailsResource.data?.estimatedDeliveryAt;

                  final hasValidTime =
                      estimatedTime != null && estimatedTime.trim().isNotEmpty;

                  return Text(
                    hasValidTime
                        ? '${AppStrings.arriveBy.tr()} $estimatedTime'
                        : AppStrings.notDetermined.tr(),
                    style: TextStyle(
                      color: hasValidTime ? colors.success : colors.darkGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}