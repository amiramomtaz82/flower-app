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

  LocationService() : _nominatim = NominatimFlutter.instance {
    _nominatim.configureNominatim(
      userAgent: 'FlowerApp/1.0',
    );
  }
  @visibleForTesting
  LocationService.test(this._nominatim);

  ////=========================current location===================
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition();

    return LatLng(
      position.latitude,
      position.longitude,
    );
  }

  ///--------------------- reverse geo code--------------------------------------------
  Future<LocationModel> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
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

    debugPrint('========== NOMINATIM RAW ADDRESS ==========');
    debugPrint('$address');
    debugPrint('============================================');
    return LocationModel(
      lat: lat,
      lng: lng,
      addressLine: address?['road'],
      city: address?['city'] ??
          address?['town'] ??
          address?['municipality'],
      area: address?['suburb'] ??
          address?['neighbourhood'],
    );
  }

  String? _buildAddressLine(dynamic address) {
    if (address == null) {
      return null;
    }

    final parts = <String?>[
      address.houseNumber,
      address.road,
    ];

    final filtered = parts
        .where((part) => part != null && part!.trim().isNotEmpty)
        .map((part) => part!.trim())
        .toList();

    if (filtered.isEmpty) {
      return null;
    }

    return filtered.join(', ');
  }

  AddressEntity getClosestAddress(List<AddressEntity> addresses, LatLng current) {
    const distance = Distance();
    AddressEntity closest = addresses.first;
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
    return closest;
  }
}