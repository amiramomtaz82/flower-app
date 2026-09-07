import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';

/// success : true
/// message : "Request completed successfully"
/// data : [...]

class AreasWithCityResponse {
  AreasWithCityResponse({
    this.success,
    this.message,
    this.data,
  });

  AreasWithCityResponse.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(AreaDto.fromJson(v));
      });
    }
  }

  bool? success;
  String? message;
  List<AreaDto>? data;

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
  AreaDto({
    this.id,
    this.name,
    this.cities,
  });

  AreaDto.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    if (json['cities'] != null) {
      cities = [];
      json['cities'].forEach((v) {
        cities?.add(CityDto.fromJson(v));
      });
    }
  }

  String? id;
  String? name;
  List<CityDto>? cities;

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
      cities: cities?.map((city) => city.toEntity()).toList() ?? [],
    );
  }
}

class CityDto {
  CityDto({
    this.id,
    this.name,
  });

  CityDto.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  String? id;
  String? name;

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