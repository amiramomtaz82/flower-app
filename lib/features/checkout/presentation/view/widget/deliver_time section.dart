import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/date_time_extension.dart';
import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_state.dart';

class CheckoutDeliveryTimeSection extends StatelessWidget {
  const CheckoutDeliveryTimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final successColor = colors?.success ?? const Color(0xFF0CB359);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.deliveryTime.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
                Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.watch_later_outlined,
                size: 20,
                color: colors?.black ?? Colors.black,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BlocBuilder<CheckoutCubit, CheckoutState>(
                  buildWhen: (prev, curr) =>
                  prev.estimateDeliveryResource != curr.estimateDeliveryResource ||
                      prev.checkoutDetailsResource != curr.checkoutDetailsResource,
                  builder: (context, state) {
                    final isEstimateLoading = state.estimateDeliveryResource.isLoading;
                    final isDetailsLoading = state.checkoutDetailsResource.isLoading;

                    if (isEstimateLoading || isDetailsLoading) {
                      return Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: successColor,
                          ),
                        ),
                      );
                    }

                    final estimatedTime = state.estimateDeliveryResource.data?.estimatedDeliveryAt ??
                        state.checkoutDetailsResource.data?.estimatedDeliveryAt;

                    final formattedDate = estimatedTime.toDeliveryFormat(context);
                    final hasTime = formattedDate.isNotEmpty;

                    if (!hasTime) {
                      return Text(
                        AppStrings.notDetermined.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors?.grey ?? Colors.grey.shade600,
                        ),
                      );
                    }

                    final instantLabel = AppStrings.instant.tr().trimRight();
                    final instantText = instantLabel.endsWith(',') || instantLabel.endsWith('،')
                        ? '$instantLabel '
                        : '$instantLabel, ';

                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: instantText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors?.black ?? Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '${AppStrings.arriveBy.tr()} $formattedDate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: successColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}