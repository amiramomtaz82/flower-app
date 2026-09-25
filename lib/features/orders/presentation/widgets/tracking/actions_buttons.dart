import 'package:easy_localization/easy_localization.dart';

import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/order_tracking_cubit.dart';
import '../../manager/order_tracking_events.dart';
import '../../manager/order_tracking_states.dart';

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colors?.primary ?? colorScheme.primary;
    final cubit = context.read<OrderTrackingCubit>();

    return BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
      buildWhen: (prev, curr) =>
      prev.trackingResource.data?.awaitingCustomerConfirmation !=
          curr.trackingResource.data?.awaitingCustomerConfirmation ||
          prev.confirmationResource != curr.confirmationResource,
      builder: (context, state) {
        final isAwaiting = state.trackingResource.data?.awaitingCustomerConfirmation ?? false;

        if (!isAwaiting) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => cubit.doEvents(const ToggleMapEvent(true)),
              child: Text(
                AppStrings.showMap.tr(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
              ),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => cubit.doEvents(const ToggleMapEvent(true)),
                child: Text(
                  AppStrings.showMap.tr(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: state.confirmationResource.isLoading ? null : () => cubit.doEvents(const ConfirmDeliveryPressedEvent()),
                child: state.confirmationResource.isLoading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary))
                    : Text(
                  AppStrings.orderDelivered.tr(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}