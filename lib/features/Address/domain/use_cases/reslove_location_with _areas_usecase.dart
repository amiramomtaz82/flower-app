import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../core/location/location_model.dart';
import '../entities/area_entity.dart';
import '../entities/city_entity.dart';
import '../entities/geocoded_location_result.dart';
import '../repo/address_repo.dart';

@injectable
class ResolveLocationWithAreasUseCase {
  final AddressRepo _addressRepo;

  ResolveLocationWithAreasUseCase(this._addressRepo);

  String _normalize(String? value) {
    if (value == null) return '';
    return value
        .toLowerCase()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<BaseResponse<GeocodedLocationResult>> call({
    required LatLng location,
    required List<AreaEntity> areas,
  }) async {
    final response = await _addressRepo.reverseGeocode(
      lat: location.latitude,
      lng: location.longitude,
    );

    switch (response) {
      case SuccessResponse<LocationModel>(:final data):
        final geocodedArea = _normalize(data.area);
        final geocodedCity = _normalize(data.city);

        AreaEntity? matchedArea;
        CityEntity? matchedCity;

        // 1. Try finding parent Area first
        for (final area in areas) {
          if (_normalize(area.name) == geocodedArea) {
            matchedArea = area;
            break;
          }
        }

        // 2. Check if city is inside the matched Area
        if (matchedArea != null) {
          for (final city in matchedArea.cities) {
            if (_normalize(city.name) == geocodedCity) {
              matchedCity = city;
              break;
            }
          }
        }

        // 3. Fallback: Search all areas if area was missed or city wasn't in it
        if (matchedArea == null || matchedCity == null) {
          for (final area in areas) {
            for (final city in area.cities) {
              if (_normalize(city.name) == geocodedCity) {
                matchedArea = area;
                matchedCity = city;
                break;
              }
            }
            if (matchedCity != null) break;
          }
        }

        return SuccessResponse(
          GeocodedLocationResult(
            location: location,
            details: data,
            matchedArea: matchedArea,
            matchedCity: matchedCity,
          ),
        );

      case ErrorResponse<LocationModel>():
        return ErrorResponse(
          error: response.error,
          errMessage: response.errMessage,
        );
    }
  }
}