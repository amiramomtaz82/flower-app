class CreateAddressRequest {
  final String recipientName;
  final String phone;
  final String addressLine;
  final String cityId;
  final String areaId;
  final num latitude;
  final num longitude;
  final String label;

  CreateAddressRequest({
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.cityId,
    required this.areaId,
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientName': recipientName,
      'phone': phone,
      'addressLine': addressLine,
      'cityId': cityId,
      'areaId': areaId,
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
    };
  }

  factory CreateAddressRequest.fromJson(Map<String, dynamic> json) {
    return CreateAddressRequest(
      recipientName: json['recipientName'] as String,
      phone: json['phone'] as String,
      addressLine: json['addressLine'] as String,
      cityId: json['cityId'] as String,
      areaId: json['areaId'] as String,
      latitude: json['latitude'] as num,
      longitude: json['longitude'] as num,
      label: json['label'] as String,
    );
  }
}