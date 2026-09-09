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

  LocationPermission checkPermissionResult = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;
  int requestPermissionCallCount = 0;
  int checkPermissionCallCount = 0;
  int getCurrentPositionCallCount = 0;

  bool shouldThrowOnGetCurrentPosition = false;

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
    return serviceEnabled;
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
    fakeNominatim = FakeNominatimFlutter();
    locationService = LocationService(fakeNominatim, fakeGeolocatorPlatform);
  });

  // ============================================================
  // Atomic GPS & Permission Helpers
  // ============================================================
  group('isServiceEnabled', () {
    test('returns true when location services are enabled', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;

      final result = await locationService.isServiceEnabled();

      expect(result, isTrue);
    });

    test('returns false when location services are disabled', () async {
      fakeGeolocatorPlatform.serviceEnabled = false;

      final result = await locationService.isServiceEnabled();

      expect(result, isFalse);
    });
  });

  group('checkPermission', () {
    test('delegates call to Geolocator.checkPermission', () async {
      fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.denied;

      final result = await locationService.checkPermission();

      expect(result, equals(LocationPermission.denied));
      expect(fakeGeolocatorPlatform.checkPermissionCallCount, 1);
    });
  });

  group('requestPermission', () {
    test('delegates call to Geolocator.requestPermission', () async {
      fakeGeolocatorPlatform.requestPermissionResult = LocationPermission.whileInUse;

      final result = await locationService.requestPermission();

      expect(result, equals(LocationPermission.whileInUse));
      expect(fakeGeolocatorPlatform.requestPermissionCallCount, 1);
    });
  });

  group('getCurrentPosition', () {
    test('returns LatLng when position is successfully resolved', () async {
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

      final result = await locationService.getCurrentPosition();

      expect(result, equals(const LatLng(29.96, 31.25)));
      expect(fakeGeolocatorPlatform.getCurrentPositionCallCount, 1);
    });

    test('returns null when getCurrentPosition throws without falling back to stale position', () async {
      fakeGeolocatorPlatform.shouldThrowOnGetCurrentPosition = true;

      final result = await locationService.getCurrentPosition();

      expect(result, isNull);
      expect(fakeGeolocatorPlatform.getCurrentPositionCallCount, 1);
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

    test('returns coordinates with null fields when Address map is null', () async {
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

    // Distance ~15 meters away
    const closeAddress = AddressEntity(
      id: 'addr_close',
      lat: 30.0001,
      lng: 31.0001,
      addressLine: 'Nearby Street',
      isDefault: false,
    );

    // Distance ~75 km away
    const farAddress = AddressEntity(
      id: 'addr_far',
      lat: 30.5000,
      lng: 31.5000,
      addressLine: 'Far Street',
      isDefault: false,
    );

    const defaultFarAddress = AddressEntity(
      id: 'addr_default_far',
      lat: 30.5000,
      lng: 31.5000,
      addressLine: 'Far Street Default',
      isDefault: true,
    );

    test('returns null if Address list is empty', () {
      final result = locationService.getClosestAddress([], currentPoint);

      expect(result, isNull);
    });

    test('returns closest Address when it falls within maxRangeMeters', () {
      final addresses = [farAddress, closeAddress];

      final result = locationService.getClosestAddress(
        addresses,
        currentPoint,
        maxRangeMeters: 500.0,
      );

      expect(result?.id, equals('addr_close'));
    });

    test('returns default Address when all addresses are outside maxRangeMeters', () {
      final addresses = [farAddress, defaultFarAddress];

      final result = locationService.getClosestAddress(
        addresses,
        currentPoint,
        maxRangeMeters: 500.0,
      );

      expect(result?.id, equals('addr_default_far'));
    });

    test('returns null when all addresses are outside maxRangeMeters and no default exists', () {
      final addresses = [farAddress];

      final result = locationService.getClosestAddress(
        addresses,
        currentPoint,
        maxRangeMeters: 500.0,
      );

      expect(result, isNull);
    });

    test('ignores addresses with null coordinates and returns close Address within range', () {
      const nullCoordAddress = AddressEntity(
        id: 'addr_null_coords',
        lat: null,
        lng: null,
        isDefault: false,
      );

      final addresses = [nullCoordAddress, farAddress, closeAddress];

      final result = locationService.getClosestAddress(
        addresses,
        currentPoint,
        maxRangeMeters: 500.0,
      );

      expect(result?.id, equals('addr_close'));
    });

    test('returns default Address if all addresses lack coordinates', () {
      const nullAddress1 = AddressEntity(id: 'null_1', lat: null, lng: null, isDefault: false);
      const nullDefault = AddressEntity(id: 'null_default', lat: null, lng: null, isDefault: true);

      final result = locationService.getClosestAddress(
        [nullAddress1, nullDefault],
        currentPoint,
      );

      expect(result?.id, equals('null_default'));
    });

    test('returns null if all coordinates are null and none is marked as default', () {
      const nullAddress1 = AddressEntity(id: 'null_1', lat: null, lng: null, isDefault: false);
      const nullAddress2 = AddressEntity(id: 'null_2', lat: null, lng: null, isDefault: false);

      final result = locationService.getClosestAddress(
        [nullAddress1, nullAddress2],
        currentPoint,
      );

      expect(result, isNull);
    });
  });
}