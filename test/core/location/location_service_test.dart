import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nominatim_flutter/model/request/reverse_request.dart';

import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:flower_app/core/location/location_model.dart';
import 'package:flower_app/core/location/location_service.dart';

import 'location_service_test.mocks.dart';

// Fake platform for Geolocator static calls
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  @override
  Future<bool> isLocationServiceEnabled() => super.noSuchMethod(
    Invocation.method(#isLocationServiceEnabled, []),
    returnValue: Future.value(true),
  );

  @override
  Future<LocationPermission> checkPermission() => super.noSuchMethod(
    Invocation.method(#checkPermission, []),
    returnValue: Future.value(LocationPermission.always),
  );

  @override
  Future<LocationPermission> requestPermission() => super.noSuchMethod(
    Invocation.method(#requestPermission, []),
    returnValue: Future.value(LocationPermission.always),
  );

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      super.noSuchMethod(
        Invocation.method(#getCurrentPosition, [], {
          #locationSettings: locationSettings,
        }),
        returnValue: Future.value(
          Position(
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
          ),
        ),
      );
}

@GenerateMocks([NominatimFlutter])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocationService locationService;
  late MockGeolocatorPlatform mockGeolocatorPlatform;
  late MockNominatimFlutter mockNominatim;

  setUp(() {
    mockGeolocatorPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocatorPlatform;

    mockNominatim = MockNominatimFlutter();
    locationService = LocationService(nominatim: mockNominatim);
  });

  group('getCurrentLocation', () {
    test('throws Exception when location services are disabled', () async {
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

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
          when(mockGeolocatorPlatform.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          when(mockGeolocatorPlatform.checkPermission())
              .thenAnswer((_) async => LocationPermission.denied);
          when(mockGeolocatorPlatform.requestPermission())
              .thenAnswer((_) async => LocationPermission.denied);

          expect(
                () => locationService.getCurrentLocation(),
            throwsA(
              isA<Exception>().having(
                    (e) => e.toString(),
                'message',
                contains('Location permission denied.'),
              ),
            ),
          );

          verify(mockGeolocatorPlatform.requestPermission()).called(1);
        });

    test('throws Exception when permission is deniedForever', () async {
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      expect(
            () => locationService.getCurrentLocation(),
        throwsA(
          isA<Exception>().having(
                (e) => e.toString(),
            'message',
            contains('Location permission permanently denied.'),
          ),
        ),
      );

      verifyNever(mockGeolocatorPlatform.requestPermission());
    });

    test('returns LatLng when permissions are granted and location is fetched',
            () async {
          final tPosition = Position(
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

          when(mockGeolocatorPlatform.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          when(mockGeolocatorPlatform.checkPermission())
              .thenAnswer((_) async => LocationPermission.whileInUse);
          when(mockGeolocatorPlatform.getCurrentPosition(
            locationSettings: anyNamed('locationSettings'),
          )).thenAnswer((_) async => tPosition);

          final result = await locationService.getCurrentLocation();

          expect(result, equals(const LatLng(29.96, 31.25)));
          verify(mockGeolocatorPlatform.getCurrentPosition()).called(1);
        });
  });

  group('reverseGeocode', () {
    const tLat = 29.96;
    const tLng = 31.25;

    test('returns LocationModel with correctly parsed city and area', () async {
      final mockReverseResponse = ReverseResponse(
        placeId: 1,
        licence: 'Data © OpenStreetMap contributors',
        osmType: 'node',
        osmId: 12345,
        lat: '$tLat',
        lon: '$tLng',
        displayName: 'Street 9, Maadi, Cairo, Egypt',
        address: {
          'road': 'Street 9',
          'city': 'Cairo',
          'suburb': 'Maadi',
        },
        boundingbox: [],
      );

      when(
        mockNominatim.reverse(
          reverseRequest: anyNamed('reverseRequest'),
          language: anyNamed('language'),
        ),
      ).thenAnswer((_) async => mockReverseResponse);

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

      verify(
        mockNominatim.reverse(
          reverseRequest: argThat(
            isA<ReverseRequest>()
                .having((r) => r.lat, 'lat', tLat)
                .having((r) => r.lon, 'lon', tLng)
                .having((r) => r.addressDetails, 'addressDetails', isTrue),
          ),
          language: 'en',
        ),
      ).called(1);
    });

    test('falls back to town/municipality for city and neighbourhood for area',
            () async {
          final mockReverseResponse = ReverseResponse(
            placeId: 2,
            licence: 'Data © OpenStreetMap contributors',
            osmType: 'node',
            osmId: 67890,
            lat: '$tLat',
            lon: '$tLng',
            displayName: 'El Rehab, New Cairo',
            address: {
              'town': 'New Cairo',
              'neighbourhood': 'El Rehab',
            },
            boundingbox: [],
          );

          when(
            mockNominatim.reverse(
              reverseRequest: anyNamed('reverseRequest'),
              language: anyNamed('language'),
            ),
          ).thenAnswer((_) async => mockReverseResponse);

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