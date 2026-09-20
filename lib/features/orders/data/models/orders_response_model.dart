import 'package:json_annotation/json_annotation.dart';
import 'package:flower_app/features/orders/data/models/order_model.dart';

part 'orders_response_model.g.dart';

@JsonSerializable()
class OrdersResponseModel {
  @JsonKey(name: 'orders', defaultValue: [])
  final List<OrderModel> orders;

  @JsonKey(name: 'pageNumber')
  final int? pageNumber;

  @JsonKey(name: 'pageSize')
  final int? pageSize;

  @JsonKey(name: 'totalCount')
  final int? totalCount;

  @JsonKey(name: 'totalPages')
  final int? totalPages;

  @JsonKey(name: 'hasNextPage')
  final bool? hasNextPage;

  @JsonKey(name: 'hasPreviousPage')
  final bool? hasPreviousPage;

  const OrdersResponseModel({
    required this.orders,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('orders')) {
      return _$OrdersResponseModelFromJson(json);
    } else if (json.containsKey('data') && json['data'] is Map && json['data'].containsKey('orders')) {
      return _$OrdersResponseModelFromJson(json['data']);
    } else if (json.containsKey('data') && json['data'] is List) {
       return OrdersResponseModel(
         orders: (json['data'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList(),
         pageNumber: json['pageNumber'] as int?,
         pageSize: json['pageSize'] as int?,
         totalCount: json['totalCount'] as int?,
         totalPages: json['totalPages'] as int?,
         hasNextPage: json['hasNextPage'] as bool?,
         hasPreviousPage: json['hasPreviousPage'] as bool?,
       );
    }
    return _$OrdersResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrdersResponseModelToJson(this);
}
