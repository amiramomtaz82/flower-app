import 'package:json_annotation/json_annotation.dart';
import 'package:flower_app/features/orders/data/models/order_model.dart';

part 'orders_response_model.g.dart';

@JsonSerializable()
class OrdersResponseModel {
  @JsonKey(name: 'orders', defaultValue: [])
  final List<OrderModel> orders;

  const OrdersResponseModel({required this.orders});

  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('orders')) {
      return _$OrdersResponseModelFromJson(json);
    } else if (json.containsKey('data') && json['data'] is Map && json['data'].containsKey('orders')) {
      return _$OrdersResponseModelFromJson(json['data']);
    } else if (json.containsKey('data') && json['data'] is List) {
       return OrdersResponseModel(
         orders: (json['data'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList(),
       );
    }
    return _$OrdersResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrdersResponseModelToJson(this);
}
