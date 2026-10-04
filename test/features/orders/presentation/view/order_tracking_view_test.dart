import 'dart:async';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/orders/domain/entities/current_location_entity.dart';
import 'package:flower_app/features/orders/domain/entities/driver_entity.dart';
import 'package:flower_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flower_app/features/orders/domain/entities/user_address_entity.dart';
import 'package:flower_app/features/orders/domain/oredr_details_entity.dart';
import 'package:flower_app/features/orders/presentation/manager/order_tracking_cubit.dart';
import 'package:flower_app/features/orders/presentation/manager/order_tracking_events.dart';
import 'package:flower_app/features/orders/presentation/view/order_dlivered_view.dart';
import 'package:flower_app/features/orders/presentation/view/order_tracking_view.dart';
import 'package:flower_app/features/orders/presentation/widgets/tracking/actions_buttons.dart';
import 'package:flower_app/features/orders/presentation/widgets/tracking/tracking_map_widget.dart';
import 'package:flower_app/features/orders/presentation/widgets/tracking/tracking_timeline_widget.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_order_by_id_ue_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../manager/order_tracking_cubit_test.mocks.dart';

Widget _wrap(Widget child, {List<RouteBase>? extraRoutes}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      if (extraRoutes != null) ...extraRoutes,
    ],
  );

  return MaterialApp.router(
    theme: ThemeData(
      extensions: [LightColors()],
    ),
    routerConfig: router,
  );
}

void main() {
  late MockGetOrderLiveTrackingUseCase mockGetOrderLiveTrackingUseCase;
  late MockConfirmOrderDeliveryUseCase mockConfirmOrderDeliveryUseCase;
  late MockGetOrderByIdUseCase mockGetOrderByIdUseCase;
  late OrderTrackingCubit cubit;

  const tOrderId = 'test-order-123';

  final tDriver = const DriverEntity(
    driverId: 'driver-1',
    name: 'Mohamed',
    phone: '+201012345678',
  );

  final tAddress = const UserAddressEntity(
    lat: 30.0444,
    lng: 31.2357,
    addressLine: '123 Test St',
  );

  final tLocation = CurrentLocationEntity(
    lat: 30.0488,
    lng: 31.2330,
    recordedAt: DateTime.now(),
    isStale: false,
  );

  final tTrackingEntity = OrderTrackingEntity(
    orderId: tOrderId,
    status: TrackingStepStatus.outForDelivery,
    isLive: true,
    awaitingCustomerConfirmation: false,
    driver: tDriver,
    currentLocation: tLocation,
    userAddress: tAddress,
    milestones: const [],
  );

  final tDeliveredTrackingEntity = OrderTrackingEntity(
    orderId: tOrderId,
    status: TrackingStepStatus.delivered,
    isLive: false,
    awaitingCustomerConfirmation: false,
    driver: tDriver,
    currentLocation: tLocation,
    userAddress: tAddress,
    milestones: const [],
  );

  const tOrderDetails = OrderDetailsEntity(
    orderId: tOrderId,
    customerName: 'Nour',
    addressTitle: 'Home',
    addressDetail: '269VP+Q2 - Sheikh Zayed',
    paymentMethod: 'Pay with cash',
    currency: 'EGP',
    subTotal: 1000,
    deliveryFee: 105,
    total: 1105,
    items: [
      OrderItemEntity(
        id: '1',
        productName: 'Red roses',
        description: '18 Pink Rose Bouquet',
        price: 600,
        quantity: 1,
      ),
    ],
  );

  setUp(() {
    mockGetOrderLiveTrackingUseCase = MockGetOrderLiveTrackingUseCase();
    mockConfirmOrderDeliveryUseCase = MockConfirmOrderDeliveryUseCase();
    mockGetOrderByIdUseCase = MockGetOrderByIdUseCase();

    provideDummy<BaseResponse<OrderTrackingEntity>>(
      SuccessResponse(tTrackingEntity),
    );
    provideDummy<BaseResponse<bool>>(
      const SuccessResponse(true),
    );
    provideDummy<BaseResponse<OrderDetailsEntity>>(
      const SuccessResponse(tOrderDetails),
    );

    cubit = OrderTrackingCubit(
      mockGetOrderLiveTrackingUseCase,
      mockConfirmOrderDeliveryUseCase,
      mockGetOrderByIdUseCase,
    );

    if (getIt.isRegistered<OrderTrackingCubit>()) {
      getIt.unregister<OrderTrackingCubit>();
    }
    getIt.registerFactory<OrderTrackingCubit>(() => cubit);

    if (getIt.isRegistered<GetOrderByIdUseCase>()) {
      getIt.unregister<GetOrderByIdUseCase>();
    }
    getIt.registerFactory<GetOrderByIdUseCase>(() => mockGetOrderByIdUseCase);
  });

  tearDown(() {
    if (getIt.isRegistered<OrderTrackingCubit>()) {
      getIt.unregister<OrderTrackingCubit>();
    }
    if (getIt.isRegistered<GetOrderByIdUseCase>()) {
      getIt.unregister<GetOrderByIdUseCase>();
    }
    cubit.close();
  });

  group('OrderTrackingView Widget Tests', () {
    testWidgets('shows loading CircularProgressIndicator while fetching tracking data',
        (WidgetTester tester) async {
      final completer = Completer<BaseResponse<OrderTrackingEntity>>();
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error view with retry button when loading fails',
        (WidgetTester tester) async {
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Connection failed'));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pumpAndSettle();

      expect(find.text('Connection failed'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders timeline, driver card, and only showMap button when tracking is not delivered',
        (WidgetTester tester) async {
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => SuccessResponse(tTrackingEntity));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pumpAndSettle();

      // Driver info is rendered
      expect(find.text('Mohamed'), findsOneWidget);

      // Tracking timeline widget is rendered
      expect(find.byType(TrackingTimelineWidget), findsOneWidget);

      // Action buttons section is rendered
      expect(find.byType(ActionButtonsSection), findsOneWidget);

      // Only Show map button is present; Order Delivered button is NOT present
      expect(find.text('showMap'), findsOneWidget);
      expect(find.text('orderDelivered'), findsNothing);
    });

    testWidgets('navigates to OrderDeliveredView when status is delivered',
        (WidgetTester tester) async {
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => SuccessResponse(tDeliveredTrackingEntity));
      when(mockGetOrderByIdUseCase.call(tOrderId))
          .thenAnswer((_) async => const SuccessResponse(tOrderDetails));

      await tester.pumpWidget(
        _wrap(
          const OrderTrackingView(orderId: tOrderId),
          extraRoutes: [
            GoRoute(
              path: AppRoutes.orderDelivered,
              builder: (context, state) {
                final id = state.extra is String ? state.extra as String : tOrderId;
                return OrderDeliveredView(
                  orderId: id,
                  orderDetails: tOrderDetails,
                );
              },
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // OrderDeliveredView should now be displayed via replacement navigation
      expect(find.byType(OrderDeliveredView), findsOneWidget);
      expect(find.text('269VP+Q2 - Sheikh Zayed'), findsOneWidget);
      expect(find.text('Red roses'), findsOneWidget);
    });

    testWidgets('renders waiting for driver status when driver is not yet assigned',
        (WidgetTester tester) async {
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => ErrorResponse(
                errMessage: 'Tracking is only available once a driver accepts the order.',
              ));
      when(mockGetOrderByIdUseCase.call(tOrderId))
          .thenAnswer((_) async => const SuccessResponse(tOrderDetails));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Should render the tracking screen, NOT an error screen
      expect(find.byType(TrackingTimelineWidget), findsOneWidget);
      expect(find.text('waitingForDriver'), findsOneWidget);
      expect(find.text('showMap'), findsOneWidget);
    });

    testWidgets('updates and renders driver card when transitioning from waiting state to driver assigned',
        (WidgetTester tester) async {
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => ErrorResponse(
                errMessage: 'Tracking is only available once a driver accepts the order.',
              ));
      when(mockGetOrderByIdUseCase.call(tOrderId))
          .thenAnswer((_) async => const SuccessResponse(tOrderDetails));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('waitingForDriver'), findsOneWidget);
      expect(find.text('Mohamed'), findsNothing);

      // Now driver accepts order
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => SuccessResponse(tTrackingEntity));

      cubit.doEvents(const RefreshTrackingEvent());
      await tester.pumpAndSettle();

      // View should now display driver name
      expect(find.text('waitingForDriver'), findsNothing);
      expect(find.text('Mohamed'), findsOneWidget);
    });

    testWidgets('renders both showMap and orderDelivered buttons when status is awaitingConfirmation',
        (WidgetTester tester) async {
      final tAwaitingConfirmationEntity = tTrackingEntity.copyWith(
        status: TrackingStepStatus.awaitingConfirmation,
        awaitingCustomerConfirmation: true,
      );

      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => SuccessResponse(tAwaitingConfirmationEntity));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pumpAndSettle();

      // Both Show map and Order Delivered buttons should be visible
      expect(find.text('showMap'), findsOneWidget);
      expect(find.text('orderDelivered'), findsOneWidget);
    });

    testWidgets('toggles from timeline to map view when showMap button is tapped and toggles back',
        (WidgetTester tester) async {
      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => SuccessResponse(tTrackingEntity));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pumpAndSettle();

      // Initially timeline view
      expect(find.byType(TrackingTimelineWidget), findsOneWidget);
      expect(find.byType(TrackingMapWidget), findsNothing);
      expect(find.text('showMap'), findsOneWidget);

      // Tap showMap button
      await tester.tap(find.text('showMap'));
      await tester.pumpAndSettle();

      // Now TrackingMapWidget should be rendered
      expect(find.byType(TrackingMapWidget), findsOneWidget);
      expect(find.byType(TrackingTimelineWidget), findsNothing);
      expect(find.text('Mohamed'), findsOneWidget);
      expect(find.text('orderDetails'), findsOneWidget);

      // Tap orderDetails to toggle back to timeline
      await tester.tap(find.text('orderDetails'));
      await tester.pumpAndSettle();

      expect(find.byType(TrackingTimelineWidget), findsOneWidget);
      expect(find.byType(TrackingMapWidget), findsNothing);
    });

    testWidgets('renders both orderDetails and orderDelivered buttons on map when awaitingConfirmation',
        (WidgetTester tester) async {
      final tAwaitingConfirmationEntity = tTrackingEntity.copyWith(
        status: TrackingStepStatus.awaitingConfirmation,
        awaitingCustomerConfirmation: true,
      );

      when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
          .thenAnswer((_) async => SuccessResponse(tAwaitingConfirmationEntity));

      await tester.pumpWidget(_wrap(const OrderTrackingView(orderId: tOrderId)));
      await tester.pumpAndSettle();

      // Tap showMap button
      await tester.tap(find.text('showMap'));
      await tester.pumpAndSettle();

      // Now on the map, both orderDetails and orderDelivered should be visible
      expect(find.byType(TrackingMapWidget), findsOneWidget);
      expect(find.text('orderDetails'), findsOneWidget);
      expect(find.text('orderDelivered'), findsOneWidget);
    });
  });
}
