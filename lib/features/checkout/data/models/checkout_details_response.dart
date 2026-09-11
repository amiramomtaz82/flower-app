import '../../domain/entities/checkout_details_entity.dart';

class CheckoutDetailsResponse {
  CheckoutDetailsResponse({
    this.success,
    this.message,
    this.data,
    this.error,
  });

  CheckoutDetailsResponse.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CheckoutDetailsDto.fromJson(json['data']) : null;
    error = json['error'];
  }

  bool? success;
  String? message;
  CheckoutDetailsDto? data;
  dynamic error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['error'] = error;
    return map;
  }
}

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

class PaymentMethodOptionDto {
  PaymentMethodOptionDto({
    this.method,
    this.gateways,
  });

  PaymentMethodOptionDto.fromJson(dynamic json) {
    method = json['method'];
    if (json['gateways'] != null) {
      gateways = List<String>.from(json['gateways'].map((x) => x.toString()));
    } else {
      gateways = [];
    }
  }

  String? method;
  List<String>? gateways;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['method'] = method;
    if (gateways != null) {
      map['gateways'] = gateways;
    }
    return map;
  }

  PaymentMethodOptionEntity toEntity() {
    return PaymentMethodOptionEntity(
      method: method ?? '',
      gateways: gateways ?? [],
    );
  }
}