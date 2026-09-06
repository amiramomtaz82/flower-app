import 'package:flower_app/core/location/location_model.dart';
import 'package:flower_app/core/location/location_service.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';


class FakeGeolocatorPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  bool serviceEnabled = true;
  bool serviceEnabledAfterPrompt = false;
  int openLocationSettingsCallCount = 0;

  LocationPermission checkPermissionResult = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;
  int requestPermissionCallCount = 0;
  int checkPermissionCallCount = 0;
  int getCurrentPositionCallCount = 0;
  int getLastKnownPositionCallCount = 0;

  bool shouldThrowOnGetCurrentPosition = false;
  Position? lastKnownPositionResult;

  Position positionResult = Position(
    longitude: 31.25,
    latitude: 29.96,
    timestamp: DateTime(2026),
    accuracy: 10.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );

  @override
  Future<bool> isLocationServiceEnabled() async {
    if (openLocationSettingsCallCount > 0) {
      return serviceEnabledAfterPrompt;
    }
    return serviceEnabled;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCallCount++;
    return true;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    checkPermissionCallCount++;
    return checkPermissionResult;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCallCount++;
    return requestPermissionResult;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    getCurrentPositionCallCount++;
    if (shouldThrowOnGetCurrentPosition) {
      throw Exception('Timeout or location error');
    }
    return positionResult;
  }

  @override
  Future<Position?> getLastKnownPosition({bool forceLocationManager = false}) async {
    getLastKnownPositionCallCount++;
    return lastKnownPositionResult;
  }
}

class FakeNominatimResponse extends NominatimResponse {
  @override
  final Map<String, dynamic>? address;

  FakeNominatimResponse({this.address});
}

class FakeNominatimFlutter extends Fake implements NominatimFlutter {
  NominatimResponse nextResponse = FakeNominatimResponse();
  bool shouldThrow = false;

  @override
  void configureNominatim({
    String? baseUrl,
    bool convertFormData = false,
    bool enableCurlLog = false,
    Duration maxStale = const Duration(days: 7),
    bool printOnSuccess = false,
    bool useCacheInterceptor = false,
    String? userAgent,
  }) {}

  @override
  Future<NominatimResponse> reverse({
    required ReverseRequest reverseRequest,
    String? language,
  }) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return nextResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocationService locationService;
  late FakeGeolocatorPlatform fakeGeolocatorPlatform;
  late FakeNominatimFlutter fakeNominatim;

  setUp(() {
    fakeGeolocatorPlatform = FakeGeolocatorPlatform();
    GeolocatorPlatform.instance = fakeGeolocatorPlatform;

    fakeNominatim = FakeNominatimFlutter();
    locationService = LocationService.test(fakeNominatim);
  });

  // ============================================================
  // getCurrentLocation
  // ============================================================
  group('getCurrentLocation', () {
    test('returns null when location services remain disabled after prompt', () async {
      fakeGeolocatorPlatform.serviceEnabled = false;
      fakeGeolocatorPlatform.serviceEnabledAfterPrompt = false;

      final result = await locationService.getCurrentLocation();

      expect(result, isNull);
      expect(fakeGeolocatorPlatform.openLocationSettingsCallCount, 1);
      expect(fakeGeolocatorPlatform.checkPermissionCallCount, 0);
    });

    test('continues and fetches location if service is enabled after prompt', () async {
      fakeGeolocatorPlatform.serviceEnabled = false;
      fakeGeolocatorPlatform.serviceEnabledAfterPrompt = true;
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.whileInUse;

      final result = await locationService.getCurrentLocation();

      expect(result, equals(const LatLng(29.96, 31.25)));
      expect(fakeGeolocatorPlatform.openLocationSettingsCallCount, 1);
      expect(fakeGeolocatorPlatform.getCurrentPositionCallCount, 1);
    });

    test('requests permission and returns null when permission is denied', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.denied;
      fakeGeolocatorPlatform.requestPermissionResult = LocationPermission.denied;

      final result = await locationService.getCurrentLocation();

      expect(result, isNull);
      expect(fakeGeolocatorPlatform.checkPermissionCallCount, 1);
      expect(fakeGeolocatorPlatform.requestPermissionCallCount, 1);
    });

    test('returns null when permission is deniedForever without requesting', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.deniedForever;

      final result = await locationService.getCurrentLocation();

      expect(result, isNull);
      expect(fakeGeolocatorPlatform.checkPermissionCallCount, 1);
      expect(fakeGeolocatorPlatform.requestPermissionCallCount, 0);
    });

    test('returns LatLng when permissions are granted and location is fetched', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.whileInUse;
      fakeGeolocatorPlatform.positionResult = Position(
        latitude: 29.96,
        longitude: 31.25,
        timestamp: DateTime(2026),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final result = await locationService.getCurrentLocation();

      expect(result, equals(const LatLng(29.96, 31.25)));
      expect(fakeGeolocatorPlatform.getCurrentPositionCallCount, 1);
    });

    test('falls back to last known position when getCurrentPosition fails', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.always;
      fakeGeolocatorPlatform.shouldThrowOnGetCurrentPosition = true;
      fakeGeolocatorPlatform.lastKnownPositionResult = Position(
        latitude: 30.05,
        longitude: 31.30,
        timestamp: DateTime(2026),
        accuracy: 15.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final result = await locationService.getCurrentLocation();

      expect(result, equals(const LatLng(30.05, 31.30)));
      expect(fakeGeolocatorPlatform.getLastKnownPositionCallCount, 1);
    });

    test('returns null when getCurrentPosition throws and last known position is null', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.always;
      fakeGeolocatorPlatform.shouldThrowOnGetCurrentPosition = true;
      fakeGeolocatorPlatform.lastKnownPositionResult = null;

      final result = await locationService.getCurrentLocation();

      expect(result, isNull);
      expect(fakeGeolocatorPlatform.getLastKnownPositionCallCount, 1);
    });
  });

  // ============================================================
  // reverseGeocode
  // ============================================================
  group('reverseGeocode', () {
    const tLat = 29.96;
    const tLng = 31.25;

    test('returns LocationModel with house number and road concatenated', () async {
      fakeNominatim.nextResponse = FakeNominatimResponse(
        address: {
          'house_number': '12',
          'road': 'Street 9',
          'city': 'Cairo',
          'suburb': 'Maadi',
        },
      );

      final result = await locationService.reverseGeocode(
        lat: tLat,
        lng: tLng,
      );

      expect(
        result,
        equals(
          const LocationModel(
            lat: tLat,
            lng: tLng,
            addressLine: '12 Street 9',
            city: 'Cairo',
            area: 'Maadi',
          ),
        ),
      );
    });

    test('falls back to pedestrian/footway for road and state for city', () async {
      fakeNominatim.nextResponse = FakeNominatimResponse(
        address: {
          'pedestrian': 'Nile Walk',
          'state': 'Cairo Governorate',
          'quarter': 'Zamalek',
        },
      );

      final result = await locationService.reverseGeocode(
        lat: tLat,
        lng: tLng,
      );

      expect(result?.addressLine, equals('Nile Walk'));
      expect(result?.city, equals('Cairo Governorate'));
      expect(result?.area, equals('Zamalek'));
    });

    test('falls back to display_name when no road tags are available', () async {
      fakeNominatim.nextResponse = FakeNominatimResponse(
        address: {
          'display_name': 'Unknown Landmark, Giza',
          'city': 'Giza',
        },
      );

      final result = await locationService.reverseGeocode(
        lat: tLat,
        lng: tLng,
      );

      expect(result?.addressLine, equals('Unknown Landmark, Giza'));
      expect(result?.city, equals('Giza'));
    });

    test('returns coordinates with null fields when address map is null', () async {
      fakeNominatim.nextResponse = FakeNominatimResponse(address: null);

      final result = await locationService.reverseGeocode(
        lat: tLat,
        lng: tLng,
      );

      expect(result?.lat, tLat);
      expect(result?.lng, tLng);
      expect(result?.addressLine, isNull);
      expect(result?.city, isNull);
      expect(result?.area, isNull);
    });

    test('handles exceptions gracefully and returns coordinates model', () async {
      fakeNominatim.shouldThrow = true;

      final result = await locationService.reverseGeocode(
        lat: tLat,
        lng: tLng,
      );

      expect(result?.lat, tLat);
      expect(result?.lng, tLng);
      expect(result?.addressLine, isNull);
    });
  });

  // ============================================================
  // getClosestAddress
  // ============================================================
  group('getClosestAddress', () {
    const currentPoint = LatLng(30.0000, 31.0000);

    const closeAddress = AddressEntity(
      id: 'addr_close',
      lat: 30.0001,
      lng: 31.0001,
      addressLine: 'Nearby Street',
    );

    const farAddress = AddressEntity(
      id: 'addr_far',
      lat: 30.5000,
      lng: 31.5000,
      addressLine: 'Far Street',
    );

    test('returns null if address list is empty', () {
      final result = locationService.getClosestAddress([], currentPoint);

      expect(result, isNull);
    });

    test('returns the closest address from the list', () {
      final addresses = [farAddress, closeAddress];

      final result = locationService.getClosestAddress(addresses, currentPoint);

      expect(result?.id, equals('addr_close'));
    });

    test('ignores addresses with null coordinates and returns valid closest', () {
      const nullCoordAddress = AddressEntity(
        id: 'addr_null_coords',
        lat: null,
        lng: null,
      );

      final addresses = [nullCoordAddress, farAddress, closeAddress];

      final result = locationService.getClosestAddress(addresses, currentPoint);

      expect(result?.id, equals('addr_close'));
    });

    test('returns first address if all coordinates in list are null', () {
      const nullAddress1 = AddressEntity(id: 'null_1', lat: null, lng: null);
      const nullAddress2 = AddressEntity(id: 'null_2', lat: null, lng: null);

      final result = locationService.getClosestAddress(
        [nullAddress1, nullAddress2],
        currentPoint,
      );

      expect(result?.id, equals('null_1'));
    });
  });
}