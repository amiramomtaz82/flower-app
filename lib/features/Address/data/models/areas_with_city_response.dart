import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';

/// success : true
/// message : "Request completed successfully"
/// data : [{"id":"c1000000-0000-0000-0000-000000000001","name":"Cairo","areas":[{"id":"a1000000-0000-0000-0000-000000000001","name":"Maadi"}]}]
/// error : null
class CitiesWithAreasResponse {
  CitiesWithAreasResponse({
      this.success,
      this.message,
      this.data,
      this.error,});

  CitiesWithAreasResponse.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(CityDto.fromJson(v));
      });
    }
    error = json['error'];
  }
  bool? success;
  String? message;
  List<CityDto>? data;
  dynamic error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['error'] = error;
    return map;
  }
}

/// id : "c1000000-0000-0000-0000-000000000001"
/// name : "Cairo"
/// areas : [{"id":"a1000000-0000-0000-0000-000000000001","name":"Maadi"}]
class CityDto {
  CityDto({
      this.id,
      this.name,
      this.areas,});

  CityDto.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    if (json['areas'] != null) {
      areas = [];
      json['areas'].forEach((v) {
        areas?.add(AreaDto.fromJson(v));
      });
    }
  }
  String? id;
  String? name;
  List<AreaDto>? areas;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    if (areas != null) {
      map['areas'] = areas?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  CityEntity toEntity() {
    return CityEntity(
      id: id ?? '',
      name: name ?? '',
      areas: areas?.map((area) => area.toEntity()).toList() ?? [],
    );
  }
}

/// id : "a1000000-0000-0000-0000-000000000001"
/// name : "Maadi"
class AreaDto {
  AreaDto({
      this.id,
      this.name,});

  AreaDto.fromJson(dynamic json) {
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

  AreaEntity toEntity() {
    return AreaEntity(
      id: id ?? '',
      name: name ?? '',
    );
  }
}
