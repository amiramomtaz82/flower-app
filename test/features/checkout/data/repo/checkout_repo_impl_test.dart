import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/checkout/data/data_source/checkout_remote_data_source.dart';
import 'package:flower_app/features/checkout/data/models/checkout_details_response.dart';
import 'package:flower_app/features/checkout/data/models/estimated_delivery_response.dart';
import 'package:flower_app/features/checkout/data/models/place_order_request.dart';
import 'package:flower_app/features/checkout/data/models/place_order_response.dart';
import 'package:flower_app/features/checkout/data/repo/checkout_repo_impl.dart';
import 'package:flower_app/features/checkout/domain/entities/checkout_details_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/estimated_delivery_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/gift_recipient_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/oder_placment_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/place_order_request_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'checkout_repo_impl_test.mocks.dart';

@GenerateMocks([CheckoutRemoteDataSource])
void main() {
  late CheckoutRepositoryImpl repository;
  late MockCheckoutRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    provideDummy<BaseResponse<CheckoutDetailsResponse>>(
      ErrorResponse<CheckoutDetailsResponse>(error: 'dummy'),
    );
    provideDummy<BaseResponse<EstimateDeliveryResponse>>(
      ErrorResponse<EstimateDeliveryResponse>(error: 'dummy'),
    );
    provideDummy<BaseResponse<PlaceOrderResponse>>(
      ErrorResponse<PlaceOrderResponse>(error: 'dummy'),
    );
  });

  setUp(() {
    mockRemoteDataSource = MockCheckoutRemoteDataSource();
    repository = CheckoutRepositoryImpl(mockRemoteDataSource);
  });

  // ============================================================
  // getCheckoutDetails
  // ============================================================
  group('getCheckoutDetails', () {
    const tCartId = 'cart_test_123';

    test('returns SuccessResponse with mapped CheckoutDetailsEntity on success', () async {
      final tDto = CheckoutDetailsDto(
        cartId: tCartId,
        addressId: 'addr_123',
        isServiceable: true,
        subtotal: 1000.0,
        deliveryFee: 50.0,
        total: 1050.0,
        estimatedDeliveryAt: '2026-09-06T12:00:00Z',
        paymentMethods: [
          PaymentMethodOption(method: 'COD'),
        ],
        isGift: false,
      );

      final tResponse = CheckoutDetailsResponse(
        isSuccess: true,
        message: 'Success',
        statusCode: '200',
        data: tDto,
      );

      when(mockRemoteDataSource.getCheckoutDetails(tCartId))
          .thenAnswer((_) async => SuccessResponse(tResponse));

      final result = await repository.getCheckoutDetails(tCartId);

      expect(result, isA<SuccessResponse<CheckoutDetailsEntity>>());
      final success = result as SuccessResponse<CheckoutDetailsEntity>;
      expect(success.data.cartId, equals(tDto.cartId));
      expect(success.data.addressId, equals(tDto.addressId));
      expect(success.data.subtotal, equals(tDto.subtotal));
      expect(success.data.deliveryFee, equals(tDto.deliveryFee));
      expect(success.data.total, equals(tDto.total));
      expect(success.data.isServiceable, equals(tDto.isServiceable));
      verify(mockRemoteDataSource.getCheckoutDetails(tCartId)).called(1);
    });

    test('returns ErrorResponse when remote data source returns ErrorResponse', () async {
      final tError = Exception('Failed to load checkout details');
      when(mockRemoteDataSource.getCheckoutDetails(tCartId))
          .thenAnswer((_) async => ErrorResponse(error: tError));

      final result = await repository.getCheckoutDetails(tCartId);

      expect(result, isA<ErrorResponse<CheckoutDetailsEntity>>());
      final errorResult = result as ErrorResponse<CheckoutDetailsEntity>;
      expect(errorResult.error, equals(tError));
      verify(mockRemoteDataSource.getCheckoutDetails(tCartId)).called(1);
    });
  });

  // ============================================================
  // estimateDelivery
  // ============================================================
  group('estimateDelivery', () {
    const tAddressId = 'addr_test_123';
    const tCartId = 'cart_test_123';

    test('returns SuccessResponse with mapped EstimateDeliveryEntity on success', () async {
      final tDto = EstimateDeliveryDto(
        addressId: tAddressId,
        isServiceable: true,
        deliveryFee: 20.0,
        estimatedDeliveryAt: '2026-09-06T15:00:00Z',
      );

      final tResponse = EstimateDeliveryResponse(
        isSuccess: true,
        message: 'Success',
        statusCode: '200',
        data: tDto,
      );

      when(mockRemoteDataSource.estimateDelivery(tAddressId, tCartId))
          .thenAnswer((_) async => SuccessResponse(tResponse));

      final result = await repository.estimateDelivery(tAddressId, tCartId);

      expect(result, isA<SuccessResponse<EstimateDeliveryEntity>>());
      final success = result as SuccessResponse<EstimateDeliveryEntity>;
      expect(success.data.addressId, equals(tDto.addressId));
      expect(success.data.deliveryFee, equals(tDto.deliveryFee));
      expect(success.data.isServiceable, equals(tDto.isServiceable));
      expect(success.data.estimatedDeliveryAt, equals(tDto.estimatedDeliveryAt));
      verify(mockRemoteDataSource.estimateDelivery(tAddressId, tCartId)).called(1);
    });

    test('returns ErrorResponse when remote data source returns ErrorResponse', () async {
      final tError = Exception('Delivery estimation failed');
      when(mockRemoteDataSource.estimateDelivery(tAddressId, tCartId))
          .thenAnswer((_) async => ErrorResponse(error: tError));

      final result = await repository.estimateDelivery(tAddressId, tCartId);

      expect(result, isA<ErrorResponse<EstimateDeliveryEntity>>());
      final errorResult = result as ErrorResponse<EstimateDeliveryEntity>;
      expect(errorResult.error, equals(tError));
      verify(mockRemoteDataSource.estimateDelivery(tAddressId, tCartId)).called(1);
    });
  });

  // ============================================================
  // placeOrder
  // ============================================================
  group('placeOrder', () {
    test('places order with COD and maps OrderPlacementEntity correctly', () async {
      final tOrderEntity = PlaceOrderRequestEntity(
        cartId: 'cart_1',
        addressId: 'addr_1',
        paymentMethod: 'COD',
        isGift: false,
      );

      final tResponse = PlaceOrderResponse(
        isSuccess: true,
        message: 'Order Placed',
        statusCode: '201',
        data: null,
      );

      when(mockRemoteDataSource.placeOrder(argThat(
        isA<PlaceOrderRequest>()
            .having((r) => r.cartId, 'cartId', 'cart_1')
            .having((r) => r.addressId, 'addressId', 'addr_1')
            .having((r) => r.paymentMethod, 'paymentMethod', 'COD')
            .having((r) => r.isGift, 'isGift', false)
            .having((r) => r.giftRecipient, 'giftRecipient', isNull),
      ))).thenAnswer((_) async => SuccessResponse(tResponse));

      final result = await repository.placeOrder(tOrderEntity);

      expect(result, isA<SuccessResponse<OrderPlacementEntity>>());
      final success = result as SuccessResponse<OrderPlacementEntity>;
      expect(success.data.isSuccess, isTrue);
      expect(success.data.cardSession, isNull);
    });

    test('maps giftRecipient when isGift is true and paymentMethod is Card', () async {
      final tOrderEntity = PlaceOrderRequestEntity(
        cartId: 'cart_2',
        addressId: 'addr_2',
        paymentMethod: 'Card',
        paymentGateway: 'Paymob',
        isGift: true,
        giftRecipient: GiftRecipientEntity(
          name: 'Ahmed',
          phone: '01000000000',
        ),
      );

      final tCardDto = CardPaymentSessionDto(
        orderId: 'ORD-123',
        status: 'Pending',
        gateway: 'Paymob',
        sessionId: 'sess-123',
        sessionUrl: 'https://pay.example.com',
        successUrl: 'flowery://success',
        cancelUrl: 'flowery://cancel',
        expiresAt: '2026-09-06T16:00:00Z',
        amount: 1200.0,
        currency: 'EGP',
        estimatedDeliveryAt: '2026-09-06T18:00:00Z',
      );

      final tResponse = PlaceOrderResponse(
        isSuccess: true,
        message: 'Payment Created',
        statusCode: '201',
        data: tCardDto,
      );

      when(mockRemoteDataSource.placeOrder(argThat(
        isA<PlaceOrderRequest>()
            .having((r) => r.cartId, 'cartId', 'cart_2')
            .having((r) => r.isGift, 'isGift', true)
            .having((r) => r.paymentGateway, 'paymentGateway', 'Paymob')
            .having((r) => r.giftRecipient?.recipientName, 'recipientName', 'Ahmed')
            .having((r) => r.giftRecipient?.recipientPhone, 'recipientPhone', '01000000000'),
      ))).thenAnswer((_) async => SuccessResponse(tResponse));

      final result = await repository.placeOrder(tOrderEntity);

      expect(result, isA<SuccessResponse<OrderPlacementEntity>>());
      final success = result as SuccessResponse<OrderPlacementEntity>;
      expect(success.data.isSuccess, isTrue);
      expect(success.data.cardSession?.orderId, equals(tCardDto.orderId));
      expect(success.data.cardSession?.sessionId, equals(tCardDto.sessionId));
      expect(success.data.cardSession?.gateway, equals(tCardDto.gateway));
      expect(success.data.cardSession?.status, equals(tCardDto.status));
      expect(success.data.cardSession?.amount, equals(tCardDto.amount));
    });

    test('returns ErrorResponse when remote data source returns ErrorResponse', () async {
      final tOrderEntity = PlaceOrderRequestEntity(
        cartId: 'cart_3',
        addressId: 'addr_3',
        paymentMethod: 'COD',
      );

      final tError = Exception('Failed to place order');
      when(mockRemoteDataSource.placeOrder(any))
          .thenAnswer((_) async => ErrorResponse(error: tError));

      final result = await repository.placeOrder(tOrderEntity);

      expect(result, isA<ErrorResponse<OrderPlacementEntity>>());
      final errorResult = result as ErrorResponse<OrderPlacementEntity>;
      expect(errorResult.error, equals(tError));
    });
  });
}