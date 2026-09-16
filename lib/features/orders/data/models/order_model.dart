import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderModel extends OrderEntity {
  const OrderModel({
    @JsonKey(name: '_id') required super.id,
    @JsonKey(name: 'productName') required super.productName,
    @JsonKey(name: 'imageUrl') required super.imageUrl,
    @JsonKey(name: 'currency') required super.currency,
    @JsonKey(name: 'price') required super.price,
    @JsonKey(name: 'status') required this.statusString,
    @JsonKey(name: 'orderNumber') super.orderNumber,
    @JsonKey(name: 'deliveredOn') super.deliveredOn,
  }) : super(
          status: statusString == 'completed'
              ? OrderStatus.completed
              : OrderStatus.active,
        );

  final String statusString;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
