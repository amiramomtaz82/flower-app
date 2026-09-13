import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/ui_action/ui_action.dart';
import 'package:flower_app/core/ui_action/ui_action_dispatcher.dart';
import 'package:flower_app/features/cart/domain/entities/cart_entity.dart';
import 'package:flower_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flower_app/features/cart/domain/use_cases/add_to_cart_use_case.dart';
import 'package:flower_app/features/cart/domain/use_cases/get_cart_use_case.dart';
import 'package:flower_app/features/cart/domain/use_cases/remove_cart_item_use_case.dart';
import 'package:flower_app/features/cart/domain/use_cases/update_cart_item_quantity_use_case.dart';
import 'package:flower_app/features/cart/presentation/manager/cart_cubit.dart';
import 'package:flower_app/features/cart/presentation/manager/cart_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cart_cubit_test.mocks.dart';

@GenerateMocks([
  GetCartUseCase,
  AddToCartUseCase,
  UpdateCartItemQuantityUseCase,
  RemoveCartItemUseCase,
  UiActionDispatcher,
])
void main() {
  late MockGetCartUseCase mockGetCartUseCase;
  late MockAddToCartUseCase mockAddToCartUseCase;
  late MockUpdateCartItemQuantityUseCase mockUpdateCartItemQuantityUseCase;
  late MockRemoveCartItemUseCase mockRemoveCartItemUseCase;
  late MockUiActionDispatcher mockUiActionDispatcher;
  late CartCubit cubit;

  const cartItem = CartItemEntity(
    id: 'item-1',
    productId: 'product-1',
    productName: 'Fresh Flower Arrangement',
    unitPrice: 150,
    quantity: 2,
    lineSubtotal: 300,
  );

  const cart = CartEntity(
    id: 'cart-1',
    items: [cartItem],
    subtotal: 300,
    total: 300,
  );

  setUpAll(() {
    provideDummy<BaseResponse<CartEntity>>(const SuccessResponse(cart));
  });

  setUp(() {
    mockGetCartUseCase = MockGetCartUseCase();
    mockAddToCartUseCase = MockAddToCartUseCase();
    mockUpdateCartItemQuantityUseCase = MockUpdateCartItemQuantityUseCase();
    mockRemoveCartItemUseCase = MockRemoveCartItemUseCase();
    mockUiActionDispatcher = MockUiActionDispatcher();

    cubit = CartCubit(
      mockGetCartUseCase,
      mockAddToCartUseCase,
      mockUpdateCartItemQuantityUseCase,
      mockRemoveCartItemUseCase,
      mockUiActionDispatcher,
    );
  });

  tearDown(() => cubit.close());

  List<String> dispatchedSuccessMessages() {
    return verify(mockUiActionDispatcher.dispatch(captureAny))
        .captured
        .whereType<ShowSnackBarAction>()
        .where((action) => action.type == SnackBarType.success)
        .map((action) => action.message)
        .toList();
  }

  List<String> dispatchedErrorMessages() {
    return verify(mockUiActionDispatcher.dispatch(captureAny))
        .captured
        .whereType<ShowSnackBarAction>()
        .where((action) => action.type == SnackBarType.error)
        .map((action) => action.message)
        .toList();
  }

  group('initial state', () {
    test('starts empty and idle', () {
      expect(cubit.state.cartResource.status, ApiStatus.initial);
      expect(cubit.state.cart, isNull);
      expect(cubit.state.itemsCount, 0);
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.mutatingId, isNull);
    });
  });

  group('CartLoaded', () {
    test('emits loading then success with the cart', () async {
      when(mockGetCartUseCase()).thenAnswer(
        (_) async => const SuccessResponse(cart),
      );

      final future = cubit.doEvents(CartLoaded());

      expect(cubit.state.cartResource.isLoading, true);

      await future;

      expect(cubit.state.cartResource.isSuccess, true);
      expect(cubit.state.cart, cart);
      expect(cubit.state.itemsCount, 2);
    });

    test('emits error and keeps no cart on failure', () async {
      when(mockGetCartUseCase()).thenAnswer(
        (_) async => ErrorResponse<CartEntity>(errMessage: 'boom'),
      );

      await cubit.doEvents(CartLoaded());

      expect(cubit.state.cartResource.status, ApiStatus.error);
      expect(cubit.state.cartResource.errorMessage, 'boom');
      expect(cubit.state.cart, isNull);
    });

    test('does not show a snackbar when the read fails', () async {
      when(mockGetCartUseCase()).thenAnswer(
        (_) async => ErrorResponse<CartEntity>(errMessage: 'boom'),
      );

      await cubit.doEvents(CartLoaded());

      verifyNever(mockUiActionDispatcher.dispatch(any));
    });
  });

  group('CartItemAdded', () {
    test('passes the product and quantity through to the use case', () async {
      when(
        mockAddToCartUseCase(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      await cubit.doEvents(
        CartItemAdded(productId: 'product-1', quantity: 3),
      );

      verify(
        mockAddToCartUseCase(productId: 'product-1', quantity: 3),
      ).called(1);
      expect(cubit.state.cart, cart);
    });

    test('marks the product as mutating while the call is in flight', () async {
      when(
        mockAddToCartUseCase(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      final future = cubit.doEvents(CartItemAdded(productId: 'product-1'));

      expect(cubit.state.mutatingId, 'product-1');

      await future;

      expect(cubit.state.mutatingId, isNull);
    });

    test('announces the add through the app-wide snackbar', () async {
      when(
        mockAddToCartUseCase(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      await cubit.doEvents(CartItemAdded(productId: 'product-1'));

      expect(dispatchedSuccessMessages(), [AppStrings.productAddedToCart]);
    });

    test('a failed add reports the error and keeps the cart on screen',
        () async {
      when(mockGetCartUseCase()).thenAnswer(
        (_) async => const SuccessResponse(cart),
      );
      await cubit.doEvents(CartLoaded());

      when(
        mockAddToCartUseCase(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        ),
      ).thenAnswer((_) async => ErrorResponse<CartEntity>(errMessage: 'nope'));

      await cubit.doEvents(CartItemAdded(productId: 'product-2'));

      expect(dispatchedErrorMessages(), ['nope']);
      expect(cubit.state.cart, cart);
      expect(cubit.state.cartResource.status, ApiStatus.success);
      expect(cubit.state.mutatingId, isNull);
    });
  });

  group('CartItemQuantityChanged', () {
    test('updates by product id and stays silent on success', () async {
      when(
        mockUpdateCartItemQuantityUseCase(
          productId: anyNamed('productId'),
          quantity: anyNamed('quantity'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      await cubit.doEvents(
        CartItemQuantityChanged(productId: 'product-1', quantity: 5),
      );

      verify(
        mockUpdateCartItemQuantityUseCase(
          productId: 'product-1',
          quantity: 5,
        ),
      ).called(1);
      verifyNever(mockUiActionDispatcher.dispatch(any));
    });
  });

  group('CartItemRemoved', () {
    test('removes by cart item id, not product id', () async {
      when(
        mockRemoveCartItemUseCase(cartItemId: anyNamed('cartItemId')),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      await cubit.doEvents(CartItemRemoved('item-1'));

      verify(mockRemoveCartItemUseCase(cartItemId: 'item-1')).called(1);
    });

    test('announces the removal', () async {
      when(
        mockRemoveCartItemUseCase(cartItemId: anyNamed('cartItemId')),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      await cubit.doEvents(CartItemRemoved('item-1'));

      expect(dispatchedSuccessMessages(), [AppStrings.productRemovedFromCart]);
    });
  });

  group('state helpers a product card relies on', () {
    setUp(() async {
      when(mockGetCartUseCase()).thenAnswer(
        (_) async => const SuccessResponse(cart),
      );
      await cubit.doEvents(CartLoaded());
    });

    test('containsProduct is true only for products in the cart', () {
      expect(cubit.state.containsProduct('product-1'), isTrue);
      expect(cubit.state.containsProduct('product-2'), isFalse);
      expect(cubit.state.containsProduct(null), isFalse);
    });

    test('cartItemIdFor maps a product back to its line', () {
      expect(cubit.state.cartItemIdFor('product-1'), 'item-1');
      expect(cubit.state.cartItemIdFor('product-2'), isNull);
    });

    test('isMutating singles out the row being changed', () async {
      when(
        mockRemoveCartItemUseCase(cartItemId: anyNamed('cartItemId')),
      ).thenAnswer((_) async => const SuccessResponse(cart));

      final future = cubit.doEvents(CartItemRemoved('item-1'));

      expect(cubit.state.isMutating('item-1'), true);

      await future;

      expect(cubit.state.isMutating('item-1'), false);
    });
  });
}
