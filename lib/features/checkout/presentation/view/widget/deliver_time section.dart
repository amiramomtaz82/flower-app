import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_state.dart';



class CheckoutDeliveryTimeSection extends StatelessWidget {
  const CheckoutDeliveryTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.deliveryTime, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.watch_later_outlined, size: 18),
              const SizedBox(width: 6),
              Text(AppStrings.instant, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 4),
              BlocBuilder<CheckoutCubit, CheckoutState>(
                buildWhen: (prev, curr) =>
                prev.estimateDeliveryResource != curr.estimateDeliveryResource ||
                    prev.checkoutDetailsResource != curr.checkoutDetailsResource,
                builder: (context, state) {
                  final isEstimateLoading = state.estimateDeliveryResource.isLoading;
                  final isDetailsLoading = state.checkoutDetailsResource.isLoading;

                  if (isEstimateLoading || isDetailsLoading) {
                    return const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00897B),
                      ),
                    );
                  }

                  final estimatedTime = state.estimateDeliveryResource.data?.estimatedDeliveryAt ??
                      state.checkoutDetailsResource.data?.estimatedDeliveryAt;

                  final hasTime = estimatedTime != null && estimatedTime.trim().isNotEmpty;
                  final displayText = hasTime ? '${AppStrings.arriveBy} $estimatedTime' : AppStrings.notDetermined;

                  return Text(
                    displayText,
                    style: TextStyle(
                      color: hasTime ? const Color(0xFF00897B) : Colors.grey.shade600,
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