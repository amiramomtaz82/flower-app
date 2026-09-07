import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';

import '../../features/Address/domain/entities/address_entity.dart';
import 'location_model.dart';

@LazySingleton()
class LocationService {
  final NominatimFlutter _nominatim;

  LocationService(this._nominatim);

  // ========================= Atomic GPS & Permission Helpers =========================

  Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<LatLng?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Geolocator error or timeout: $e');
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        return LatLng(lastPosition.latitude, lastPosition.longitude);
      }
      return null;
    }
  }

  // ========================= Reverse Geocode =========================

  Future<LocationModel?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final request = ReverseRequest(
        lat: lat,
        lon: lng,
        addressDetails: true,
      );

      final response = await _nominatim.reverse(
        reverseRequest: request,
        language: 'en',
      );

      final address = response.address;

      if (address == null) {
        return LocationModel(lat: lat, lng: lng);
      }

      final road = address['road'] ?? address['pedestrian'] ?? address['footway'];
      final houseNumber = address['house_number'];
      final addressLine = (houseNumber != null && road != null)
          ? '$houseNumber $road'
          : road ?? address['display_name'];

      final city = address['city'] ??
          address['town'] ??
          address['municipality'] ??
          address['state'] ??
          address['county'];

      final area = address['suburb'] ??
          address['neighbourhood'] ??
          address['quarter'] ??
          address['residential'] ??
          address['district'];

      return LocationModel(
        lat: lat,
        lng: lng,
        addressLine: addressLine?.toString(),
        city: city?.toString(),
        area: area?.toString(),
      );
    } catch (e) {
      debugPrint('Nominatim reverse geocoding failed: $e');
      return LocationModel(lat: lat, lng: lng);
    }
  }

  // ========================= Closest Address =========================

  AddressEntity? getClosestAddress(List<AddressEntity> addresses, LatLng current) {
    if (addresses.isEmpty) return null;

    const distance = Distance();
    AddressEntity? closest;
    double minMeters = double.infinity;

    for (final addr in addresses) {
      if (addr.lat != null && addr.lng != null) {
        final meters = distance(current, LatLng(addr.lat!, addr.lng!));
        if (meters < minMeters) {
          minMeters = meters;
          closest = addr;
        }
      }
    }

    return closest ?? addresses.first;
  }
}