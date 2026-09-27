import '../../domain/oredr_details_entity.dart';
import 'order_item_model.dart';

class OrderDetailsModel {
  final String orderId;
  final String customerName;
  final String addressTitle;
  final String addressDetail;
  final String paymentMethod;
  final String currency;
  final num subTotal;
  final num deliveryFee;
  final num total;
  final List<OrderItemModel> items;

  const OrderDetailsModel({
    required this.orderId,
    required this.customerName,
    required this.addressTitle,
    required this.addressDetail,
    required this.paymentMethod,
    required this.currency,
    required this.subTotal,
    required this.deliveryFee,
    required this.total,
    required this.items,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) => OrderDetailsModel(
    orderId: json['orderId'] as String? ?? json['_id'] as String? ?? '',
    customerName: json['customerName'] as String? ?? '',
    addressTitle: json['addressTitle'] as String? ?? '',
    addressDetail: json['addressDetail'] as String? ?? '',
    paymentMethod: json['paymentMethod'] as String? ?? '',
    currency: json['currency'] as String? ?? 'EGP',
    subTotal: (json['subTotal'] as num?) ?? 0,
    deliveryFee: (json['deliveryFee'] as num?) ?? 0,
    total: (json['total'] as num?) ?? 0,
    items: (json['items'] as List<dynamic>?)
        ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
        .toList() ??
        const [],
  );
  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'customerName': customerName,
    'addressTitle': addressTitle,
    'addressDetail': addressDetail,
    'paymentMethod': paymentMethod,
    'currency': currency,
    'subTotal': subTotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'items': items.map((e) => e.toJson()).toList(),
  };

  OrderDetailsEntity toEntity() => OrderDetailsEntity(
    orderId: orderId,
    customerName: customerName,
    addressTitle: addressTitle,
    addressDetail: addressDetail,
    paymentMethod: paymentMethod,
    currency: currency,
    subTotal: subTotal,
    deliveryFee: deliveryFee,
    total: total,
    items: items.map((e) => e.toEntity()).toList(),
  );
}