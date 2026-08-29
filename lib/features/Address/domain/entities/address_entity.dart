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
  final bool? isServiceable;
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
    this.isServiceable,
    this.createdAt,
  });

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
    isServiceable,
    createdAt,
  ];
}