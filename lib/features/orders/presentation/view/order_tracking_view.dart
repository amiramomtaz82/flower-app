import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';

import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/go_routes/routes_name.dart';

import '../manager/order_tracking_cubit.dart';

import '../manager/order_tracking_events.dart';
import '../manager/order_tracking_states.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../widgets/tracking/actions_buttons.dart';
import '../widgets/tracking/driver_info_card.dart';
import '../widgets/tracking/staleness_banner.dart';
import '../widgets/tracking/tracking_map_widget.dart';
import '../widgets/tracking/tracking_timeline_widget.dart';

class OrderTrackingView extends StatelessWidget {
  final String orderId;

  const OrderTrackingView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return BlocProvider(
      create: (_) =>
          getIt<OrderTrackingCubit>()..doEvents(StartTrackingEvent(orderId)),
      child: _OrderTrackingScaffold(orderId: orderId),
    );
  }
}

class _OrderTrackingScaffold extends StatelessWidget {
  final String orderId;
  const _OrderTrackingScaffold({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final primary = colors?.primary ?? Theme.of(context).colorScheme.primary;

    return BlocListener<OrderTrackingCubit, OrderTrackingState>(
      listenWhen: (prev, curr) =>
          prev.trackingResource.data?.status != TrackingStepStatus.delivered &&
          curr.trackingResource.data?.status == TrackingStepStatus.delivered,
      listener: (context, state) {
        context.pushReplacement(
          AppRoutes.orderDelivered,
          extra: orderId,
        );
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          AppStrings.trackOrder.tr(),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        buildWhen: (prev, curr) =>
            prev.trackingResource.isLoading !=
                curr.trackingResource.isLoading ||
            prev.trackingResource.isError != curr.trackingResource.isError ||
            (prev.trackingResource.data == null &&
                curr.trackingResource.data != null),
        builder: (context, state) {
          final cubit = context.read<OrderTrackingCubit>();
          if (state.trackingResource.isLoading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }
          if (state.trackingResource.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.trackingResource.errorMessage ??
                      AppStrings.failedToLoadTracking.tr()),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary),
                    onPressed: () =>
                        cubit.doEvents(const RefreshTrackingEvent()),
                    child: Text(AppStrings.retry.tr()),
                  ),
                ],
              ),
            );
          }
          if (state.trackingResource.data == null) {
            return Center(child: CircularProgressIndicator(color: primary));
          }
          return const _TrackingBody();
        },
      ),
    ),
  );
}
}

class _TrackingBody extends StatelessWidget {
  const _TrackingBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Staleness banner (rebuilds only when staleness changes)
        BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
          buildWhen: (prev, curr) =>
              prev.isStale != curr.isStale ||
              (curr.isStale &&
                  prev.secondsSinceLastSync != curr.secondsSinceLastSync),
          builder: (context, state) {
            if (!state.isStale) return const SizedBox.shrink();
            return StalenessBanner(
              secondsSinceSync: state.secondsSinceLastSync,
              onRefresh: () => context
                  .read<OrderTrackingCubit>()
                  .doEvents(const RefreshTrackingEvent()),
            );
          },
        ),

        // 2. View switcher (Map / Timeline)
        Expanded(
          child: BlocSelector<OrderTrackingCubit, OrderTrackingState, bool>(
            selector: (state) => state.showMap,
            builder: (context, showMap) {
              final data = context
                  .read<OrderTrackingCubit>()
                  .state
                  .trackingResource
                  .data!;
              if (showMap) {
                return TrackingMapWidget(
                  data: data,
                  onSwitchToTimeline: () => context
                      .read<OrderTrackingCubit>()
                      .doEvents(const ToggleMapEvent(false)),
                );
              }
              return _TimelineSection(data: data);
            },
          ),
        ),
      ],
    );
  }
}

///=====================Timeline Section==================================================
class _TimelineSection extends StatelessWidget {
  final OrderTrackingEntity data;

  const _TimelineSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        // 1. Scrollable ListView for timeline content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              /// ============= estimated delivery =========================================
              Text(
                AppStrings.estimatedArrival.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: colors?.secondary ?? colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.estimatedDeliveryAt != null
                    ? DateFormat('dd MMM yyyy, hh:mm a', context.locale.toString())
                    .format(data.estimatedDeliveryAt!)
                    : AppStrings.notDetermined.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors?.textPrimary ?? colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),

              /// ============= driver card ================================================
              DriverInfoCard(driver: data.driver),
              const SizedBox(height: 20),

              /// ============= car image ==================================================
              Center(
                child: Image.asset(
                  AppAssets.car,
                  height: 85,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              /// ============= tracking timeline ==========================================
              TrackingTimelineWidget(
                milestones: data.milestones,
                currentStatus: data.status,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // 2. Buttons pinned at the bottom/end of the screen
        const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: ActionButtonsSection(),
          ),
        ),
      ],
    );
  }
}
//==========================================================================
