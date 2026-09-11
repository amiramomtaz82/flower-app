// lib/features/Address/domain/entities/address_entity.dart
import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String? id;
  final String? recipientName;
  final String? recipientPhone;
  final String? addressLine;
  final String? cityId;
  final String? areaId;
  final double? lat;
  final double? lng;
  final String? label;
  final bool? isDefault;
  final String? storeId;
  final bool? isServiceable; // Added property
  final String? createdAt;

  const AddressEntity({
    this.id,
    this.recipientName,
    this.recipientPhone,
    this.addressLine,
    this.cityId,
    this.areaId,
    this.lat,
    this.lng,
    this.label,
    this.isDefault,
    this.storeId,
    this.isServiceable, // Added to constructor
    this.createdAt,
  });

  AddressEntity copyWith({
    String? id,
    String? recipientName,
    String? recipientPhone,
    String? addressLine,
    String? cityId,
    String? areaId,
    double? lat,
    double? lng,
    String? label,
    bool? isDefault,
    String? storeId,
    bool? isServiceable, // Added to copyWith
    String? createdAt,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      addressLine: addressLine ?? this.addressLine,
      cityId: cityId ?? this.cityId,
      areaId: areaId ?? this.areaId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      storeId: storeId ?? this.storeId,
      isServiceable: isServiceable ?? this.isServiceable, // Mapped in copyWith
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    recipientName,
    recipientPhone,
    addressLine,
    cityId,
    areaId,
    lat,
    lng,
    label,
    isDefault,
    storeId,
    isServiceable, // Added to Equatable props
    createdAt,
  ];
}