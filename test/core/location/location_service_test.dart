import 'package:flower_app/core/location/location_model.dart';
import 'package:flower_app/core/location/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';
import 'package:nominatim_flutter/model/response/nominatim_response.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Concrete Fake Platform matching exact GeolocatorPlatform signatures
class FakeGeolocatorPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  bool serviceEnabled = true;
  LocationPermission checkPermissionResult = LocationPermission.always;
  LocationPermission requestPermissionResult = LocationPermission.always;
  int requestPermissionCallCount = 0;
  int checkPermissionCallCount = 0;
  int getCurrentPositionCallCount = 0;

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
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

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
    locationService = LocationService(nominatim: fakeNominatim);
  });

  group('getCurrentLocation', () {
    test('throws Exception when location services are disabled', () async {
      fakeGeolocatorPlatform.serviceEnabled = false;

      expect(
            () => locationService.getCurrentLocation(),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('Location services are disabled.'),
          ),
        ),
      );
    });

    test('requests permission and throws Exception when permission is denied',
            () async {
          fakeGeolocatorPlatform.serviceEnabled = true;
          fakeGeolocatorPlatform.checkPermissionResult = LocationPermission.denied;
          fakeGeolocatorPlatform.requestPermissionResult = LocationPermission.denied;

          // Notice the `await` before expect!
          await expectLater(
                () => locationService.getCurrentLocation(),
            throwsA(
              isA<Exception>().having(
                    (e) => e.toString(),
                'message',
                contains('Location permission denied.'),
              ),
            ),
          );

          expect(fakeGeolocatorPlatform.checkPermissionCallCount, 1);
          expect(fakeGeolocatorPlatform.requestPermissionCallCount, 1);
        });



    test('throws Exception when location services are disabled', () async {
      fakeGeolocatorPlatform.serviceEnabled = false;

      await expectLater(
            () => locationService.getCurrentLocation(),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('Location services are disabled.'),
          ),
        ),
      );
    });

    test('throws Exception when permission is deniedForever', () async {
      fakeGeolocatorPlatform.serviceEnabled = true;
      fakeGeolocatorPlatform.checkPermissionResult =
          LocationPermission.deniedForever;

      await expectLater(
            () => locationService.getCurrentLocation(),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('Location permission permanently denied.'),
          ),
        ),
      );

      expect(fakeGeolocatorPlatform.requestPermissionCallCount, 0);
    });

    test('returns LatLng when permissions are granted and location is fetched',
            () async {
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
  });

  group('reverseGeocode', () {
    const tLat = 29.96;
    const tLng = 31.25;

    test('returns LocationModel with correctly parsed city and area', () async {
      fakeNominatim.nextResponse = FakeNominatimResponse(
        address: {
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
            addressLine: 'Street 9',
            city: 'Cairo',
            area: 'Maadi',
          ),
        ),
      );
    });

    test('falls back to town/municipality for city and neighbourhood for area',
            () async {
          fakeNominatim.nextResponse = FakeNominatimResponse(
            address: {
              'town': 'New Cairo',
              'neighbourhood': 'El Rehab',
            },
          );

          final result = await locationService.reverseGeocode(
            lat: tLat,
            lng: tLng,
          );

          expect(result.addressLine, isNull);
          expect(result.city, equals('New Cairo'));
          expect(result.area, equals('El Rehab'));
        });
  });
}