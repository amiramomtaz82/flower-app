import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/checkout/domain/entities/checkout_details_entity.dart';
import 'package:flower_app/features/checkout/domain/entities/estimated_delivery_entity.dart';
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
    cartId: tCartId,
    addressId: tAddressId,
    isServiceable: true,
    subtotal: 100.0,
    deliveryFee: 15.0,
    total: 115.0,
    estimatedDeliveryAt: '2026-09-06T15:00:00Z',
    paymentMethods: ['COD', 'Card'],
    availableGateways: ['Paymob', 'Stripe'],
    isGift: false,
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
      'emits [loading, success] when defaultAddressId is null and API succeeds',
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
        predicate<CheckoutState>((state) => state.checkoutDetailsResource.isLoading),
        predicate<CheckoutState>((state) =>
        state.checkoutDetailsResource.isSuccess &&
            state.checkoutDetailsResource.data?.cartId == tCartId &&
            state.selectedAddressId == null),
      ],
      verify: (_) {
        verify(mockGetCheckoutDetailsUseCase(tCartId)).called(1);
        verifyZeroInteractions(mockEstimateDeliveryUseCase);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'fetches delivery estimation if defaultAddressId is provided',
      build: () {
        when(mockGetCheckoutDetailsUseCase(tCartId)).thenAnswer(
              (_) async => const SuccessResponse(tCheckoutDetails),
        );
        when(mockEstimateDeliveryUseCase(addressId: tAddressId, cartId: tCartId)).thenAnswer(
              (_) async => const SuccessResponse(tEstimatedDelivery),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const GetCheckoutDetailsEvent(cartId: tCartId, defaultAddressId: tAddressId),
      ),
      expect: () => [
        predicate<CheckoutState>((state) => state.checkoutDetailsResource.isLoading),
        predicate<CheckoutState>((state) =>
        state.checkoutDetailsResource.isSuccess &&
            state.selectedAddressId == tAddressId),
        predicate<CheckoutState>((state) =>
        state.estimateDeliveryResource.isLoading &&
            state.selectedAddressId == tAddressId),
        predicate<CheckoutState>((state) =>
        state.estimateDeliveryResource.isSuccess &&
            state.estimateDeliveryResource.data?.deliveryFee == 15.0),
      ],
      verify: (_) {
        verify(mockGetCheckoutDetailsUseCase(tCartId)).called(1);
        verify(mockEstimateDeliveryUseCase(addressId: tAddressId, cartId: tCartId)).called(1);
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
        predicate<CheckoutState>((state) => state.checkoutDetailsResource.isLoading),
        predicate<CheckoutState>((state) => state.checkoutDetailsResource.isError),
      ],
      verify: (_) {
        verify(mockGetCheckoutDetailsUseCase(tCartId)).called(1);
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
        when(mockEstimateDeliveryUseCase(addressId: tAddressId, cartId: tCartId)).thenAnswer(
              (_) async => const SuccessResponse(tEstimatedDelivery),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const EstimateDeliveryEvent(addressId: tAddressId, cartId: tCartId),
      ),
      expect: () => [
        predicate<CheckoutState>((state) =>
        state.estimateDeliveryResource.isLoading &&
            state.selectedAddressId == tAddressId),
        predicate<CheckoutState>((state) =>
        state.estimateDeliveryResource.isSuccess &&
            state.estimateDeliveryResource.data?.addressId == tAddressId),
      ],
      verify: (_) {
        verify(mockEstimateDeliveryUseCase(addressId: tAddressId, cartId: tCartId)).called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits [loading, error] when delivery estimation fails',
      build: () {
        when(mockEstimateDeliveryUseCase(addressId: tAddressId, cartId: tCartId)).thenAnswer(
              (_) async => ErrorResponse(error: Exception('Address out of reach')),
        );
        return cubit;
      },
      act: (cubit) => cubit.doEvents(
        const EstimateDeliveryEvent(addressId: tAddressId, cartId: tCartId),
      ),
      expect: () => [
        predicate<CheckoutState>((state) =>
        state.estimateDeliveryResource.isLoading &&
            state.selectedAddressId == tAddressId),
        predicate<CheckoutState>((state) => state.estimateDeliveryResource.isError),
      ],
      verify: (_) {
        verify(mockEstimateDeliveryUseCase(addressId: tAddressId, cartId: tCartId)).called(1);
      },
    );
  });

  // ============================================================
  // Payment & Gift Selection
  // ============================================================
  group('Payment & Gift Selection', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'sets payment method to cash and disables isGift',
      seed: () => CheckoutState.initial().copyWith(
        isGift: true,
        paymentMethod: PaymentMethodType.card,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(
        const SelectPaymentMethodEvent(PaymentMethodType.cash),
      ),
      expect: () => [
        predicate<CheckoutState>((state) =>
        state.paymentMethod == PaymentMethodType.cash &&
            state.isGift == false),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'switches payment method to card when currently cash',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: PaymentMethodType.cash,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(
        const SelectPaymentMethodEvent(PaymentMethodType.card),
      ),
      expect: () => [
        predicate<CheckoutState>((state) =>
        state.paymentMethod == PaymentMethodType.card),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'does NOT toggle gift when payment method is cash',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: PaymentMethodType.cash,
        isGift: false,
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const ToggleGiftEvent(true)),
      expect: () => [],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'toggles gift when payment method is card',
      seed: () => CheckoutState.initial().copyWith(
        paymentMethod: PaymentMethodType.card,
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
        predicate<CheckoutState>((state) =>
        state.recipientName == 'Omar' &&
            state.recipientPhone == '01198765432'),
      ],
    );
  });

  // ============================================================
  // PlaceOrderEvent & Validation
  // ============================================================
  group('PlaceOrderEvent Validation', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'emits error when no address is selected',
      seed: () => CheckoutState.initial().copyWith(selectedAddressId: null),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent(tCartId)),
      expect: () => [
        predicate<CheckoutState>((state) =>
        state.placeOrderResource.isError &&
            state.placeOrderResource.errorMessage == 'Please select a delivery address.'),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits error when isGift is true on card payment but recipient name or phone is empty',
      seed: () => CheckoutState.initial().copyWith(
        selectedAddressId: tAddressId,
        paymentMethod: PaymentMethodType.card,
        isGift: true,
        recipientName: '',
        recipientPhone: '',
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const PlaceOrderEvent(tCartId)),
      expect: () => [
        predicate<CheckoutState>((state) =>
        state.placeOrderResource.isError &&
            state.placeOrderResource.errorMessage ==
                'Please provide recipient name and phone number for gifts.'),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'resets place order resource on ResetPlaceOrderStateEvent',
      seed: () => CheckoutState.initial().copyWith(
        placeOrderResource: Resource.error('Some error'),
      ),
      build: () => cubit,
      act: (cubit) => cubit.doEvents(const ResetPlaceOrderStateEvent()),
      expect: () => [
        predicate<CheckoutState>((state) =>
        !state.placeOrderResource.isLoading &&
            !state.placeOrderResource.isSuccess &&
            !state.placeOrderResource.isError),
      ],
    );}
  );

  }