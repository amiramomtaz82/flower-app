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
    return OrderEntity(
      id: id,
      productName: productName,
      imageUrl: imageUrl,
      currency: currency,
      price: price,
      status: statusString == 'completed' ? OrderStatus.completed : OrderStatus.active,
      orderNumber: orderNumber?.toString(),
      deliveredOn: deliveredOn,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
