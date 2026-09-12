// lib/features/Address/data/models/areas_with_city_response.dart
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';

class AreasWithCityResponse {
  bool? success;
  String? message;
  List<AreaDto>? data;

  AreasWithCityResponse({
    this.success,
    this.message,
    this.data,
  });

  AreasWithCityResponse.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return;
    success = json['success'];
    message = json['message'];
    if (json['data'] != null && json['data'] is List) {
      data = (json['data'] as List)
          .map((v) => AreaDto.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class AreaDto {
  String? id;
  String? name;
  List<CityDto>? cities;

  AreaDto({
    this.id,
    this.name,
    this.cities,
  });

  AreaDto.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return;
    // Support both 'id' and '_id'
    id = (json['id'] ?? json['_id'])?.toString();
    name = json['name']?.toString();
    if (json['cities'] != null && json['cities'] is List) {
      cities = (json['cities'] as List)
          .map((v) => CityDto.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    if (cities != null) {
      map['cities'] = cities?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  AreaEntity toEntity() {
    return AreaEntity(
      id: id ?? '',
      name: name ?? '',
      cities: cities?.map((city) => city.toEntity()).toList() ?? const [],
    );
  }
}

class CityDto {
  String? id;
  String? name;

  CityDto({
    this.id,
    this.name,
  });

  CityDto.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return;
    // Support both 'id' and '_id'
    id = (json['id'] ?? json['_id'])?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }

  CityEntity toEntity() {
    return CityEntity(
      id: id ?? '',
      name: name ?? '',
    );
  }
}