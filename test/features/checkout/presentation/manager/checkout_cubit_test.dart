import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/checkout/domain/entities/checkout_details_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/estimated_delivery_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/oder_placment_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/place_order_request_entity.dart';
import 'package:flower_app/features/checkout/domain/usecases/estimated_delivery_usecase.dart';
import 'package:flower_app/features/checkout/domain/usecases/get_checkout_details_usecase.dart';
import 'package:flower_app/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:flower_app/features/checkout/presentation/manager/checkout_cubit.dart';
import 'package:flower_app/features/checkout/presentation/manager/checkout_event.dart';
import 'package:flower_app/features/checkout/presentation/manager/checkout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'checkout_cubit_test.mocks.dart';

@GenerateMocks([
  GetCheckoutDetailsUseCase,
  EstimateDeliveryUseCase,
  PlaceOrderUseCase,
])
void main() {
  late CheckoutCubit cubit;
  late MockGetCheckoutDetailsUseCase mockGetCheckoutDetailsUseCase;
  late MockEstimateDeliveryUseCase mockEstimateDeliveryUseCase;
  late MockPlaceOrderUseCase mockPlaceOrderUseCase;

  const tCartId = 'cart_123';
  const tAddressId = 'addr_123';

  const tCheckoutDetails = CheckoutDetailsEntity(
    subtotal: 100.0,
    deliveryFee: 15.0,
    total: 115.0,
    estimatedDeliveryAt: '2026-09-06T15:00:00Z',
    paymentMethods: [
      PaymentMethodOptionEntity(method: 'COD', gateways: []),
      PaymentMethodOptionEntity(method: 'Card', gateways: ['Paymob', 'Stripe']),
    ],
    isGift: false,
    giftRecipientName: null,
    giftRecipientPhone: null,
  );

  const tEstimatedDelivery = EstimateDeliveryEntity(
    addressId: tAddressId,
    isServiceable: true,
    deliveryFee: 15.0,
    estimatedDeliveryAt: '2026-09-06T15:00:00Z',
  );

  setUpAll(() {
    provideDummy<BaseResponse<CheckoutDetailsEntity>>(
      ErrorResponse<CheckoutDetailsEntity>(error: 'dummy'),
    );
    provideDummy<BaseResponse<EstimateDeliveryEntity>>(
      ErrorResponse<EstimateDeliveryEntity>(error: 'dummy'),
    );
    provideDummy<BaseResponse<OrderPlacementEntity>>(
      ErrorResponse<OrderPlacementEntity>(error: 'dummy'),
    );
    provideDummy<OrderPlacementEntity>(
      const OrderPlacementEntity(isSuccess: true),
    );
  });

  setUp(() {
    mockGetCheckoutDetailsUseCase = MockGetCheckoutDetailsUseCase();
    mockEstimateDeliveryUseCase = MockEstimateDeliveryUseCase();
    mockPlaceOrderUseCase = MockPlaceOrderUseCase();

    cubit = CheckoutCubit(
      mockGetCheckoutDetailsUseCase,
      mockEstimateDeliveryUseCase,
      mockPlaceOrderUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should have initial resources and default values', () {
    expect(cubit.state, equals(CheckoutState.initial()));
  });

  // ============================================================
  // GetCheckoutDetailsEvent
  // ============================================================
  group('GetCheckoutDetailsEvent', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'emits [loading, success] with first payment method when API succeeds and defaultAddressId is null',
      build: () {
        when(mockGetCheckoutDetailsUseCase(tCartId)).thenAnswer(
              (_) async => const SuccessResponse(tCheckoutDetails),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const GetCheckoutDetailsEvent(cartId: tCartId, defaultAddressId: null),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.checkoutDetailsResource.isLoading &&
              state.estimateDeliveryResource.isLoading,
        ),
        predicate<CheckoutState>(
              (state) =>
          state.checkoutDetailsResource.isSuccess &&
              state.checkoutDetailsResource.data?.total == 115.0 &&
              state.paymentMethod == 'COD' &&
              state.estimateDeliveryResource.isSuccess &&
              state.estimateDeliveryResource.data?.deliveryFee == 15.0 &&
              state.estimateDeliveryResource.data?.addressId == '',
        ),
      ],
      verify: (_) {
        verify(mockGetCheckoutDetailsUseCase(tCartId)).called(1);
        verifyZeroInteractions(mockEstimateDeliveryUseCase);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits [loading, success] with defaultAddressId when provided and API succeeds',
      build: () {
        when(mockGetCheckoutDetailsUseCase(tCartId)).thenAnswer(
              (_) async => const SuccessResponse(tCheckoutDetails),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const GetCheckoutDetailsEvent(
          cartId: tCartId,
          defaultAddressId: tAddressId,
        ),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.checkoutDetailsResource.isLoading &&
              state.estimateDeliveryResource.isLoading,
        ),
        predicate<CheckoutState>(
              (state) =>
          state.checkoutDetailsResource.isSuccess &&
              state.selectedAddressId == tAddressId &&
              state.estimateDeliveryResource.isSuccess &&
              state.estimateDeliveryResource.data?.addressId == tAddressId &&
              state.estimateDeliveryResource.data?.deliveryFee == 15.0,
        ),
      ],
      verify: (_) {
        verify(mockGetCheckoutDetailsUseCase(tCartId)).called(1);
        verifyZeroInteractions(mockEstimateDeliveryUseCase);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits [loading, error] when checkout details call fails',
      build: () {
        when(mockGetCheckoutDetailsUseCase(tCartId)).thenAnswer(
              (_) async => ErrorResponse(error: Exception('Cart not found')),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const GetCheckoutDetailsEvent(cartId: tCartId, defaultAddressId: null),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.checkoutDetailsResource.isLoading &&
              state.estimateDeliveryResource.isLoading,
        ),
        predicate<CheckoutState>(
              (state) =>
          state.checkoutDetailsResource.isError &&
              state.estimateDeliveryResource.isError,
        ),
      ],
      verify: (_) {
        verify(mockGetCheckoutDetailsUseCase(tCartId)).called(1);
        verifyZeroInteractions(mockEstimateDeliveryUseCase);
      },
    );
  });

  // ============================================================
  // EstimateDeliveryEvent
  // ============================================================
  group('EstimateDeliveryEvent', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'emits [loading, success] when delivery estimation succeeds',
      build: () {
        when(mockEstimateDeliveryUseCase(
          addressId: tAddressId,
          cartId: tCartId,
        )).thenAnswer(
              (_) async => const SuccessResponse(tEstimatedDelivery),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const EstimateDeliveryEvent(addressId: tAddressId, cartId: tCartId),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.estimateDeliveryResource.isLoading &&
              state.selectedAddressId == tAddressId,
        ),
        predicate<CheckoutState>(
              (state) =>
          state.estimateDeliveryResource.isSuccess &&
              state.estimateDeliveryResource.data?.addressId == tAddressId,
        ),
      ],
      verify: (_) {
        verify(mockEstimateDeliveryUseCase(
          addressId: tAddressId,
          cartId: tCartId,
        )).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits [loading, error] when delivery estimation fails',
      build: () {
        when(mockEstimateDeliveryUseCase(
          addressId: tAddressId,
          cartId: tCartId,
        )).thenAnswer(
              (_) async => ErrorResponse(error: Exception('Address out of reach')),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const EstimateDeliveryEvent(addressId: tAddressId, cartId: tCartId),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.estimateDeliveryResource.isLoading &&
              state.selectedAddressId == tAddressId,
        ),
        predicate<CheckoutState>(
              (state) => state.estimateDeliveryResource.isError,
        ),
      ],
      verify: (_) {
        verify(mockEstimateDeliveryUseCase(
          addressId: tAddressId,
          cartId: tCartId,
        )).called(1);
      },
    );
  });

  // ============================================================
  // Payment & Gift Selection
  // ============================================================
  group('Payment & Gift Selection', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'resets isGift to false when cash payment method is selected',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: 'Card',
        isGift: true,
        recipientName: 'Sarah',
        recipientPhone: '01012345678',
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(
        const SelectPaymentMethodEvent('COD'),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.paymentMethod == 'COD' &&
              state.isGift == false,
        ),
      ],
    );
    blocTest<CheckoutCubit, CheckoutState>(
      'maintains gift state when switching between non-cash payment methods',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: 'Card',
        isGift: true,
        recipientName: 'Omar',
        recipientPhone: '01198765432',
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(
        const SelectPaymentMethodEvent('Wallet'),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.paymentMethod == 'Wallet' &&
              state.isGift == true &&
              state.recipientName == 'Omar' &&
              state.recipientPhone == '01198765432',
        ),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'does NOT toggle gift when payment method is Cash/COD',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: 'COD',
        isGift: false,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const ToggleGiftEvent(true)),
      expect: () => [],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'toggles gift when payment method is non-cash',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: 'Card',
        isGift: false,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const ToggleGiftEvent(true)),
      expect: () => [
        predicate<CheckoutState>((state) => state.isGift == true),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'updates recipient gift details',
      build: () => cubit,
      act: (cubit) => cubit.doEvents(
        const UpdateGiftDetailsEvent(name: 'Omar', phone: '01198765432'),
      ),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.recipientName == 'Omar' &&
              state.recipientPhone == '01198765432',
        ),
      ],
    );
  });

  // ============================================================
  // PlaceOrderEvent & Validation
  // ============================================================
  group('PlaceOrderEvent Validation & Submission', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'emits error when cartId is empty',
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent('   ')),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.placeOrderResource.isError &&
              state.placeOrderResource.errorMessage ==
                  'Cart identifier is missing.',
        ),
      ],
      verify: (_) => verifyZeroInteractions(mockPlaceOrderUseCase),
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits error when no address is selected',
      seed: () => CheckoutState.initial().copyWith(selectedAddressId: null),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent(tCartId)),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.placeOrderResource.isError &&
              state.placeOrderResource.errorMessage ==
                  'Please select a delivery address.',
        ),
      ],
      verify: (_) => verifyZeroInteractions(mockPlaceOrderUseCase),
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits error when no payment method is selected',
      seed: () => CheckoutState.initial().copyWith(
        selectedAddressId: tAddressId,
        paymentMethod: null,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent(tCartId)),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.placeOrderResource.isError &&
              state.placeOrderResource.errorMessage ==
                  'Please select a payment method.',
        ),
      ],
      verify: (_) => verifyZeroInteractions(mockPlaceOrderUseCase),
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits error when isGift is true on card payment but recipient name fails validation',
      seed: () => CheckoutState.initial().copyWith(
        selectedAddressId: tAddressId,
        paymentMethod: 'Card',
        isGift: true,
        recipientName: '',
        recipientPhone: '',
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent(tCartId)),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          state.placeOrderResource.isError &&
              state.placeOrderResource.errorMessage != null,
        ),
      ],
      verify: (_) => verifyZeroInteractions(mockPlaceOrderUseCase),
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'resolves gateway from checkout details and calls placeOrderUseCase successfully',
      seed: () => CheckoutState.initial().copyWith(
        checkoutDetailsResource: Resource.success(tCheckoutDetails),
        selectedAddressId: tAddressId,
        paymentMethod: 'Card',
        isGift: false,
      ),
      build: () {
        when(mockPlaceOrderUseCase(any)).thenAnswer(
              (_) async => const SuccessResponse(OrderPlacementEntity(isSuccess: true)),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent(tCartId)),
      expect: () => [
        predicate<CheckoutState>((state) => state.placeOrderResource.isLoading),
        predicate<CheckoutState>((state) => state.placeOrderResource.isSuccess),
      ],
      verify: (_) {
        verify(
          mockPlaceOrderUseCase(
            const PlaceOrderRequestEntity(
              cartId: tCartId,
              addressId: tAddressId,
              isGift: false,
              giftRecipient: null,
              paymentMethod: 'Card',
              paymentGateway: 'Paymob',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'resets place order resource on ResetPlaceOrderStateEvent',
      seed: () => CheckoutState.initial().copyWith(
        placeOrderResource: Resource.error('Some error'),
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const ResetPlaceOrderStateEvent()),
      expect: () => [
        predicate<CheckoutState>(
              (state) =>
          !state.placeOrderResource.isLoading &&
              !state.placeOrderResource.isSuccess &&
              !state.placeOrderResource.isError,
        ),
      ],
    );
  });
}