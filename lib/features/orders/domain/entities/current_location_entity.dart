import 'package:equatable/equatable.dart';

class CurrentLocationEntity extends Equatable {
  final double lat;
  final double lng;
  final DateTime recordedAt;
  final bool isStale;
  const CurrentLocationEntity({
    required this.lat,
    required this.lng,
    required this.recordedAt,
    required this.isStale,
  });
  CurrentLocationEntity copyWith({
    double? lat,
    double? lng,
    DateTime? recordedAt,
    bool? isStale,
  }) {
    return CurrentLocationEntity(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      recordedAt: recordedAt ?? this.recordedAt,
      isStale: isStale ?? this.isStale,
    );
  }
  @override
  List<Object?> get props => [lat, lng, recordedAt, isStale];
}