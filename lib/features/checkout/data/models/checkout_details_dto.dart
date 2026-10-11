import 'package:flower_app/features/checkout/data/models/payment_methould_dto.dart';

import '../../domain/entities/checkout_details_entity.dart';

class CheckoutDetailsDto {
  CheckoutDetailsDto({
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.estimatedDeliveryAt,
    this.paymentMethods,
    this.isGift,
    this.giftRecipientName,
    this.giftRecipientPhone,
  });

  CheckoutDetailsDto.fromJson(dynamic json) {
    subtotal = json['subtotal'];
    deliveryFee = json['deliveryFee'];
    total = json['total'];
    estimatedDeliveryAt = json['estimatedDeliveryAt'];
    if (json['paymentMethods'] != null) {
      paymentMethods = [];
      json['paymentMethods'].forEach((v) {
        paymentMethods?.add(PaymentMethodOptionDto.fromJson(v));
      });
    }
    isGift = json['isGift'];
    giftRecipientName = json['giftRecipientName'];
    giftRecipientPhone = json['giftRecipientPhone'];
  }

  num? subtotal;
  num? deliveryFee;
  num? total;
  String? estimatedDeliveryAt;
  List<PaymentMethodOptionDto>? paymentMethods;
  bool? isGift;
  String? giftRecipientName;
  String? giftRecipientPhone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['subtotal'] = subtotal;
    map['deliveryFee'] = deliveryFee;
    map['total'] = total;
    map['estimatedDeliveryAt'] = estimatedDeliveryAt;
    if (paymentMethods != null) {
      map['paymentMethods'] = paymentMethods?.map((v) => v.toJson()).toList();
    }
    map['isGift'] = isGift;
    map['giftRecipientName'] = giftRecipientName;
    map['giftRecipientPhone'] = giftRecipientPhone;
    return map;
  }

  CheckoutDetailsEntity toEntity() {
    return CheckoutDetailsEntity(
      subtotal: subtotal?.toDouble() ?? 0.0,
      deliveryFee: deliveryFee?.toDouble() ?? 0.0,
      total: total?.toDouble() ?? 0.0,
      estimatedDeliveryAt: estimatedDeliveryAt,
      paymentMethods: paymentMethods?.map((p) => p.toEntity()).toList() ?? [],
      isGift: isGift ?? false,
      giftRecipientName: giftRecipientName,
      giftRecipientPhone: giftRecipientPhone,
    );
  }
}