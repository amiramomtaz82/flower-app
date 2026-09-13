import 'package:flower_app/features/cart/data/models/cart_item_dto.dart';
import 'package:flower_app/features/cart/data/models/cart_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // real response from GET /cart/cart
  Map<String, dynamic> liveResponseJson() => {
    'success': true,
    'message': 'Request completed successfully',
    'data': {
      'id': 'bfa19d7b-e7c6-48fd-ab3b-435075e5830a',
      'customerId': '01a086c8-33ee-75b4-bdc3-2e3527bbe672',
      'items': [
        {
          'id': 'd702f731-c91a-4c96-af32-2ac4f3a9d519',
          'productId': '01a086bc-f420-777f-84be-681567cc913f',
          'productName': 'Fresh Flower Arrangement',
          'productImageUrl': 'categories/tulip_flower.png',
          'unitPrice': 150.0,
          'quantity': 4,
          'lineSubtotal': 600.0,
          'inStock': true,
          'availableStock': 50,
          'priceChanged': false,
        },
      ],
      'subtotal': 900.0,
      'deliveryFee': null,
      'total': 900.0,
      'hasChanges': false,
    },
    'error': null,
  };

  group('CartResponseModel.fromJson', () {
    test('parses the envelope and the cart underneath it', () {
      final model = CartResponseModel.fromJson(liveResponseJson());

      expect(model.success, isTrue);
      expect(model.message, 'Request completed successfully');
      expect(model.error, isNull);
      expect(model.data?.id, 'bfa19d7b-e7c6-48fd-ab3b-435075e5830a');
      expect(model.data?.customerId, '01a086c8-33ee-75b4-bdc3-2e3527bbe672');
      expect(model.data?.items, hasLength(1));
      expect(model.data?.subtotal, 900.0);
      expect(model.data?.total, 900.0);
      expect(model.data?.hasChanges, isFalse);
    });

    test('keeps a null deliveryFee null rather than defaulting it', () {
      final model = CartResponseModel.fromJson(liveResponseJson());

      expect(model.data?.deliveryFee, isNull);
    });

    test('parses an error envelope with no cart', () {
      final model = CartResponseModel.fromJson({
        'success': false,
        'message': 'Cart not found',
        'data': null,
        'error': {'code': 'NOT_FOUND', 'field': 'cartId'},
      });

      expect(model.success, isFalse);
      expect(model.data, isNull);
      expect(model.error?.code, 'NOT_FOUND');
      expect(model.error?.field, 'cartId');
    });
  });

  group('CartDto.toEntity', () {
    test('maps every field through, items included', () {
      final entity = CartResponseModel.fromJson(liveResponseJson())
          .data!
          .toEntity();

      expect(entity.id, 'bfa19d7b-e7c6-48fd-ab3b-435075e5830a');
      expect(entity.customerId, '01a086c8-33ee-75b4-bdc3-2e3527bbe672');
      expect(entity.subtotal, 900.0);
      expect(entity.deliveryFee, isNull);
      expect(entity.total, 900.0);
      expect(entity.hasChanges, isFalse);
      expect(entity.items, hasLength(1));

      final item = entity.items.single;
      expect(item.id, 'd702f731-c91a-4c96-af32-2ac4f3a9d519');
      expect(item.productId, '01a086bc-f420-777f-84be-681567cc913f');
      expect(item.productName, 'Fresh Flower Arrangement');
      expect(item.productImageUrl, 'categories/tulip_flower.png');
      expect(item.unitPrice, 150.0);
      expect(item.quantity, 4);
      expect(item.lineSubtotal, 600.0);
      expect(item.inStock, isTrue);
      expect(item.availableStock, 50);
      expect(item.priceChanged, isFalse);
    });

    test('a missing items array becomes an empty cart, not a crash', () {
      final model = CartResponseModel.fromJson({
        'success': true,
        'message': 'Request completed successfully',
        'data': {'id': 'cart-1', 'subtotal': 0, 'total': 0},
        'error': null,
      });

      final entity = model.data!.toEntity();

      expect(entity.items, isEmpty);
      expect(entity.isEmpty, isTrue);
      expect(entity.itemsCount, 0);
      expect(entity.hasChanges, isFalse);
    });
  });

  group('CartItemDto.toEntity', () {
    test('defaults the flags the write endpoints leave out', () {
      const dto = CartItemDto(
        id: 'item-1',
        productId: 'product-1',
        unitPrice: 150,
        quantity: 2,
      );

      final entity = dto.toEntity();

      expect(entity.priceChanged, isFalse);
      expect(entity.inStock, isTrue);
      expect(entity.availableStock, isNull);
    });

    test('an explicit false inStock survives the default', () {
      const dto = CartItemDto(id: 'item-1', inStock: false);

      expect(dto.toEntity().inStock, isFalse);
    });
  });

  group('CartEntity', () {
    test('itemsCount sums quantities instead of counting lines', () {
      final entity = CartResponseModel.fromJson({
        'success': true,
        'data': {
          'items': [
            {'id': 'a', 'productId': 'p1', 'quantity': 4},
            {'id': 'b', 'productId': 'p2', 'quantity': 1},
          ],
        },
      }).data!.toEntity();

      expect(entity.items, hasLength(2));
      expect(entity.itemsCount, 5);
    });

    test('a line with no quantity contributes nothing to the count', () {
      final entity = CartResponseModel.fromJson({
        'success': true,
        'data': {
          'items': [
            {'id': 'a', 'productId': 'p1'},
          ],
        },
      }).data!.toEntity();

      expect(entity.itemsCount, 0);
      expect(entity.isEmpty, isFalse);
    });
  });
}
