import '../../domain/entities/checkout_details_entity.dart';

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