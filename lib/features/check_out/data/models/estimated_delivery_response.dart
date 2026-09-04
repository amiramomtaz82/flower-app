
import '../../domain/entities/estimated_delivery_entity.dart';


class EstimateDeliveryResponse {
  final EstimateDeliveryDto? data;
  final bool isSuccess;
  final String message;
  final String? messageLocalized;
  final String statusCode;

  EstimateDeliveryResponse({
    this.data,
    required this.isSuccess,
    required this.message,
    this.messageLocalized,
    required this.statusCode,
  });

  factory EstimateDeliveryResponse.fromJson(Map<String, dynamic> json) {
    return EstimateDeliveryResponse(
      data: json['data'] != null ? EstimateDeliveryDto.fromJson(json['data']) : null,
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      messageLocalized: json['messageLocalized'],
      statusCode: json['statusCode'] ?? '',
    );
  }
}

class EstimateDeliveryDto {
  final String addressId;
  final bool isServiceable;
  final double? deliveryFee;
  final String? estimatedDeliveryAt;

  EstimateDeliveryDto({
    required this.addressId,
    required this.isServiceable,
    this.deliveryFee,
    this.estimatedDeliveryAt,
  });

  factory EstimateDeliveryDto.fromJson(Map<String, dynamic> json) {
    return EstimateDeliveryDto(
      addressId: json['addressId'] ?? '',
      isServiceable: json['isServiceable'] ?? false,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      estimatedDeliveryAt: json['estimatedDeliveryAt'],
    );
  }

  EstimateDeliveryEntity toEntity() {
    return EstimateDeliveryEntity(
      addressId: addressId,
      isServiceable: isServiceable,
      deliveryFee: deliveryFee ?? 0.0,
      estimatedDeliveryAt: estimatedDeliveryAt,
    );
  }
}