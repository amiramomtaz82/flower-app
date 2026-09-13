import '../../domain/entities/estimated_delivery_entity.dart';

class EstimateDeliveryResponse {
  final EstimateDeliveryDto? data;
  final bool success;
  final String message;
  final dynamic error;

  EstimateDeliveryResponse({
    this.data,
    required this.success,
    required this.message,
    this.error,
  });

  factory EstimateDeliveryResponse.fromJson(Map<String, dynamic> json) {
    return EstimateDeliveryResponse(
      data: json['data'] != null ? EstimateDeliveryDto.fromJson(json['data']) : null,
      success: json['success'] ?? json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
    );
  }
}

class EstimateDeliveryDto {
  final String? estimatedDeliveryAt;
  final String? addressId;
  final bool isServiceable;
  final double? deliveryFee;

  EstimateDeliveryDto({
    this.estimatedDeliveryAt,
    this.addressId,
    this.isServiceable = true,
    this.deliveryFee,
  });

  factory EstimateDeliveryDto.fromJson(Map<String, dynamic> json) {
    return EstimateDeliveryDto(
      estimatedDeliveryAt: json['estimatedDeliveryAt'],
      addressId: json['addressId'],
      isServiceable: json['isServiceable'] ?? true,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
    );
  }

  EstimateDeliveryEntity toEntity({String fallbackAddressId = ''}) {
    return EstimateDeliveryEntity(
      addressId: addressId ?? fallbackAddressId,
      isServiceable: isServiceable,
      deliveryFee: deliveryFee ?? 0.0,
      estimatedDeliveryAt: estimatedDeliveryAt,
    );
  }
}