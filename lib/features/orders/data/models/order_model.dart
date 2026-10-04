// ignore_for_file: unused_element
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel {
  const OrderModel({
    @JsonKey(name: '_id') required this.id,
    @JsonKey(name: 'productName') required this.productName,
    @JsonKey(name: 'imageUrl') required this.imageUrl,
    @JsonKey(name: 'currency') required this.currency,
    @JsonKey(name: 'price') required this.price,
    @JsonKey(name: 'status') required this.statusString,
    @JsonKey(name: 'orderNumber') this.orderNumber,
    @JsonKey(name: 'deliveredOn') this.deliveredOn,
  });

  final String id;
  final String productName;
  final String imageUrl;
  final String currency;
  final double price;
  final String statusString;
  final int? orderNumber;
  final String? deliveredOn;

  OrderEntity toEntity() {
    final lowerStatus = statusString.toLowerCase();
    final isCompleted = lowerStatus == 'completed' ||
        lowerStatus == 'delivered' ||
        lowerStatus == 'cancelled';
    return OrderEntity(
      id: id,
      productName: productName,
      imageUrl: imageUrl,
      currency: currency,
      price: price,
      status: isCompleted ? OrderStatus.completed : OrderStatus.active,
      orderNumber: orderNumber?.toString(),
      deliveredOn: deliveredOn,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? json['orderId'] ?? '';
    final rawStatus = json['status']?.toString() ?? '';
    final rawOrderNumber = json['orderNumber'] ?? json['order_number'];
    final rawDeliveredOn = json['deliveredOn'] ??
        json['delivered_at'] ??
        json['estimatedDeliveryAt'] ??
        json['createdAt'];
    final rawPrice = json['price'] ?? json['total'] ?? json['totalPrice'] ?? json['subTotal'] ?? 0;
    
    String rawProduct = json['productName']?.toString() ?? json['title']?.toString() ?? json['name']?.toString() ?? '';
    String rawImage = json['imageUrl']?.toString() ?? json['image']?.toString() ?? json['thumbnailUrl']?.toString() ?? '';
    if (rawProduct.isEmpty && json['items'] is List && (json['items'] as List).isNotEmpty) {
      final firstItem = (json['items'] as List).first;
      if (firstItem is Map) {
        rawProduct = firstItem['productName']?.toString() ?? firstItem['name']?.toString() ?? '';
        rawImage = firstItem['imageUrl']?.toString() ?? firstItem['image']?.toString() ?? rawImage;
      }
    }
    if (rawProduct.isEmpty) {
      final itemCount = json['itemCount'];
      if (itemCount != null) {
        rawProduct = '$itemCount items';
      } else {
        rawProduct = 'Order';
      }
    }

    final parsedPrice = (rawPrice is num)
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice.toString()) ?? 0.0);

    return OrderModel(
      id: rawId.toString(),
      productName: rawProduct,
      imageUrl: rawImage,
      currency: json['currency']?.toString() ?? 'EGP',
      price: parsedPrice,
      statusString: rawStatus,
      orderNumber: rawOrderNumber is num
          ? rawOrderNumber.toInt()
          : int.tryParse(rawOrderNumber?.toString() ?? ''),
      deliveredOn: rawDeliveredOn?.toString(),
    );
  }

  static OrderModel fromGeneratedJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
