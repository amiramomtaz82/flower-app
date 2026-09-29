import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../manager/order_tracking_cubit.dart';
import '../../manager/order_tracking_events.dart';
import '../../manager/order_tracking_states.dart';
import '../../view/order_dlivered_view.dart';

class ActionButtonsSection extends StatelessWidget {
  final bool isMap;
  final VoidCallback? onSwitchView;

  const ActionButtonsSection({
    super.key,
    this.isMap = false,
    this.onSwitchView,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colors?.primary ?? colorScheme.primary;
    final cubit = context.read<OrderTrackingCubit>();

    return BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
      buildWhen: (prev, curr) =>
      prev.trackingResource.data?.status != curr.trackingResource.data?.status ||
          prev.confirmationResource != curr.confirmationResource ||
          prev.orderDetailsResource != curr.orderDetailsResource,
      builder: (context, state) {
        final data = state.trackingResource.data;
        // ✅ Only appears when status is strictly delivered
        final isDelivered = data?.status == TrackingStepStatus.delivered;

        final switchButtonLabel = isMap ? AppStrings.orderDetails.tr() : AppStrings.showMap.tr();
        void handleSwitchView() {
          if (onSwitchView != null) {
            onSwitchView!();
          } else {
            cubit.doEvents(ToggleMapEvent(!isMap));
          }
        }

        // 🔘 State 1: When NOT delivered -> Full Width Button
        if (!isDelivered) {
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: handleSwitchView,
              child: Text(
                switchButtonLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          );
        }

        // 🔘 State 2: When DELIVERED -> Two buttons side-by-side
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: handleSwitchView,
                child: Text(switchButtonLabel),
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
                onPressed: () {
                  if (state.confirmationResource.isLoading) return;
                  if (data?.awaitingCustomerConfirmation ?? false) {
                    cubit.doEvents(const ConfirmDeliveryPressedEvent());
                  }
                  try {
                    context.push(
                      AppRoutes.orderDelivered,
                      extra: {
                        'trackingData': data,
                        'orderDetails': state.orderDetailsResource.data,
                      },
                    );
                  } catch (_) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderDeliveredView(
                          trackingData: data,
                          orderDetails: state.orderDetailsResource.data,
                        ),
                      ),
                    );
                  }
                },
                child: state.confirmationResource.isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
                    : Text(
                  AppStrings.orderDelivered.tr(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}