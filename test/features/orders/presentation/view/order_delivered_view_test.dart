import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flower_app/features/orders/domain/entities/user_address_entity.dart';
import 'package:flower_app/features/orders/domain/oredr_details_entity.dart';
import 'package:flower_app/features/orders/presentation/view/order_dlivered_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: [LightColors()],
    ),
    home: child,
  );
}

void main() {
  const tOrderDetails = OrderDetailsEntity(
    orderId: 'order-123',
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
        id: 'item-1',
        productName: 'Red roses',
        description: '18 Pink Rose Bouquet',
        price: 600,
        quantity: 1,
      ),
      OrderItemEntity(
        id: 'item-2',
        productName: 'White tulip',
        description: '10 White Tulip Bouquet',
        price: 400,
        quantity: 1,
      ),
    ],
  );

  const tTrackingData = OrderTrackingEntity(
    orderId: 'order-123',
    status: TrackingStepStatus.delivered,
    isLive: false,
    awaitingCustomerConfirmation: false,
    userAddress: UserAddressEntity(lat: 30.0, lng: 31.0, addressLine: '269VP+Q2 - Sheikh Zayed'),
    milestones: [],
  );

  group('OrderDeliveredView Widget Tests', () {
    testWidgets('shows CircularProgressIndicator when orderDetails is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const OrderDeliveredView(
            trackingData: tTrackingData,
            orderDetails: null,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders all receipt sections when orderDetails is loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const OrderDeliveredView(
            trackingData: tTrackingData,
            orderDetails: tOrderDetails,
          ),
        ),
      );

      // 1. Delivery status header
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.textContaining('Nour'), findsWidgets);

      // 2. Address Card
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('269VP+Q2 - Sheikh Zayed'), findsOneWidget);

      // 3. Payment Card
      expect(find.text('Pay with cash'), findsOneWidget);
      expect(find.text('EGP 1105'), findsOneWidget);

      // 4. Items Card
      expect(find.text('Red roses'), findsOneWidget);
      expect(find.text('18 Pink Rose Bouquet'), findsOneWidget);
      expect(find.text('EGP 600'), findsOneWidget);
      expect(find.text('White tulip'), findsOneWidget);
      expect(find.text('EGP 400'), findsOneWidget);

      // 5. Cost Breakdown
      expect(find.text('1000'), findsOneWidget);
      expect(find.text('105'), findsOneWidget);
      expect(find.text('1105'), findsOneWidget);

      // 6. Action buttons exist
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('triggers onReorder callback when Reorder button is tapped',
        (WidgetTester tester) async {
      bool reorderTapped = false;

      await tester.pumpWidget(
        _wrap(
          OrderDeliveredView(
            trackingData: tTrackingData,
            orderDetails: tOrderDetails,
            onReorder: () => reorderTapped = true,
          ),
        ),
      );

      // The first ElevatedButton is the Reorder button
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();

      expect(reorderTapped, isTrue);
    });

    testWidgets('triggers onRate callback when Rate button is tapped',
        (WidgetTester tester) async {
      bool rateTapped = false;

      await tester.pumpWidget(
        _wrap(
          OrderDeliveredView(
            trackingData: tTrackingData,
            orderDetails: tOrderDetails,
            onRate: () => rateTapped = true,
          ),
        ),
      );

      // The second ElevatedButton is the Rate button
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      expect(rateTapped, isTrue);
    });
  });
}
