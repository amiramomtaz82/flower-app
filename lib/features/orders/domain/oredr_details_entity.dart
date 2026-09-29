import 'package:equatable/equatable.dart';

import 'entities/order_item_entity.dart';

class OrderDetailsEntity extends Equatable {
  final String orderId;
  final String customerName;
  final String addressTitle;
  final String addressDetail;
  final String paymentMethod;
  final String currency;
  final num subTotal;
  final num deliveryFee;
  final num total;
  final List<OrderItemEntity> items;
  const OrderDetailsEntity({
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
  @override
  List<Object?> get props => [
    orderId, customerName, addressTitle, addressDetail,
    paymentMethod, currency, subTotal, deliveryFee, total, items,
  ];
}