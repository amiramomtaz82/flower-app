import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/checkout/api/api_client/checkout_api_client.dart';

import 'package:flower_app/features/checkout/data/models/checkout_details_response.dart';
import 'package:flower_app/features/checkout/data/models/estimated_delivery_response.dart';
import 'package:flower_app/features/checkout/data/models/place_order_request.dart';
import 'package:flower_app/features/checkout/data/models/place_order_response.dart';
import 'package:flower_app/features/checkout/api/data_source/checkout_remote_data_source_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'checkout_remote_data_source_imp_test.mocks.dart';

@GenerateMocks([
  CheckoutApiClient,
])
void main() {
  late CheckoutRemoteDataSourceImpl remoteDataSource;
  late MockCheckoutApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockCheckoutApiClient();
    remoteDataSource = CheckoutRemoteDataSourceImpl(mockApiClient);
  });

  group('getCheckoutDetails', () {
    const tCartId = 'cart_test_123';

    test('returns SuccessResponse with mock data and does not call apiClient when in mock mode', () async {
      // Act
      final result = await remoteDataSource.getCheckoutDetails(tCartId);

      // Assert
      expect(result, isA<SuccessResponse<CheckoutDetailsResponse>>());
      final successResult = result as SuccessResponse<CheckoutDetailsResponse>;
      expect(successResult.data.isSuccess, isTrue);
      expect(successResult.data.data?.cartId, equals(tCartId));
      expect(successResult.data.data?.addressId, equals('addr-mock-001'));
      expect(successResult.data.data?.total, equals(1105.0));
      verifyZeroInteractions(mockApiClient);
    });
  });

  group('estimateDelivery', () {
    const tAddressId = 'addr_test_123';
    const tCartId = 'cart_test_123';

    test('returns SuccessResponse with mock data and does not call apiClient when in mock mode', () async {
      // Act
      final result = await remoteDataSource.estimateDelivery(tAddressId, tCartId);

      // Assert
      expect(result, isA<SuccessResponse<EstimateDeliveryResponse>>());
      final successResult = result as SuccessResponse<EstimateDeliveryResponse>;
      expect(successResult.data.isSuccess, isTrue);
      expect(successResult.data.data?.addressId, equals(tAddressId));
      expect(successResult.data.data?.deliveryFee, equals(15.0));
      expect(successResult.data.data?.isServiceable, isTrue);
      verifyZeroInteractions(mockApiClient);
    });
  });

  group('placeOrder', () {
    test('returns SuccessResponse with null data when paymentMethod is COD', () async {
      // Arrange
      final request = PlaceOrderRequest(
        cartId: 'cart_123',
        addressId: 'addr_123',
        paymentMethod: 'COD',
        isGift: false,
      );

      // Act
      final result = await remoteDataSource.placeOrder(request);

      // Assert
      expect(result, isA<SuccessResponse<PlaceOrderResponse>>());
      final successResult = result as SuccessResponse<PlaceOrderResponse>;
      expect(successResult.data.isSuccess, isTrue);
      expect(successResult.data.message, equals('Order Placed Successfully'));
      expect(successResult.data.data, isNull);
      verifyZeroInteractions(mockApiClient);
    });

    test('returns SuccessResponse with CardPaymentSessionDto when paymentMethod is Card', () async {
      // Arrange
      final request = PlaceOrderRequest(
        cartId: 'cart_123',
        addressId: 'addr_123',
        paymentMethod: 'Card',
        paymentGateway: 'Paymob',
      );

      // Act
      final result = await remoteDataSource.placeOrder(request);

      // Assert
      expect(result, isA<SuccessResponse<PlaceOrderResponse>>());
      final successResult = result as SuccessResponse<PlaceOrderResponse>;
      expect(successResult.data.isSuccess, isTrue);
      expect(successResult.data.message, equals('Payment Session Created'));
      expect(successResult.data.data, isA<CardPaymentSessionDto>());
      expect(successResult.data.data?.gateway, equals('Paymob'));
      expect(successResult.data.data?.status, equals('PendingPayment'));
      expect(successResult.data.data?.amount, equals(1105.0));
      verifyZeroInteractions(mockApiClient);
    });
  });
}