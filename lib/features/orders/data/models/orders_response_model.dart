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
    List<dynamic>? rawOrders;
    if (json['orders'] is List) {
      rawOrders = json['orders'] as List;
    } else if (json['data'] is Map && (json['data'] as Map)['orders'] is List) {
      rawOrders = (json['data'] as Map)['orders'] as List;
    } else if (json['data'] is Map && (json['data'] as Map)['items'] is List) {
      rawOrders = (json['data'] as Map)['items'] as List;
    } else if (json['data'] is List) {
      rawOrders = json['data'] as List;
    } else if (json['items'] is List) {
      rawOrders = json['items'] as List;
    }

    if (rawOrders != null) {
      final parsedOrders = rawOrders
          .whereType<Map>()
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final paginationMap = (json['data'] is Map && (json['data'] as Map)['pagination'] is Map)
          ? (json['data'] as Map)['pagination'] as Map
          : (json['pagination'] is Map ? json['pagination'] as Map : null);

      return OrdersResponseModel(
        orders: parsedOrders,
        pageNumber: (paginationMap?['page'] ?? json['pageNumber'] ?? json['page']) as int?,
        pageSize: (paginationMap?['pageSize'] ?? json['pageSize'] ?? json['limit']) as int?,
        totalCount: (paginationMap?['totalCount'] ?? json['totalCount'] ?? json['total']) as int?,
        totalPages: (paginationMap?['totalPages'] ?? json['totalPages']) as int?,
        hasNextPage: (paginationMap?['hasNextPage'] ?? json['hasNextPage']) as bool?,
        hasPreviousPage: (paginationMap?['hasPreviousPage'] ?? json['hasPreviousPage']) as bool?,
      );
    }
    return _$OrdersResponseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrdersResponseModelToJson(this);
}
