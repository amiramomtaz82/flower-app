import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/location/location_model.dart';
import 'package:flower_app/core/location/location_service.dart';
import 'package:flower_app/features/Address/data/data_source/address_remote_data_source.dart';
import 'package:flower_app/features/Address/data/models/address_dto.dart';
import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';
import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/create_address_response.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:flower_app/features/Address/data/repo/address_repo_impl.dart';
import 'package:flower_app/features/Address/domain/entities/add_address_entity.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:flower_app/features/Address/domain/entities/area_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'address_repo_impl_test.mocks.dart';

@GenerateMocks([
  AddressRemoteDataSource,
  LocationService,
])
void main() {
  late AddressRepoImpl addressRepoImpl;
  late MockAddressRemoteDataSource mockAddressRemoteDataSource;
  late MockLocationService mockLocationService;

  provideDummy<BaseResponse<SavedAddressesResponse>>(
    SuccessResponse<SavedAddressesResponse>(
      SavedAddressesResponse(data: []),
    ),
  );

  provideDummy<BaseResponse<CreateAddressResponse>>(
    SuccessResponse<CreateAddressResponse>(
      CreateAddressResponse(data: null),
    ),
  );

  provideDummy<BaseResponse<AreasWithCityResponse>>(
    SuccessResponse<AreasWithCityResponse>(
      AreasWithCityResponse(data: []),
    ),
  );

  provideDummy<BaseResponse<AddressDto>>(
    SuccessResponse<AddressDto>(
      AddressDto(),
    ),
  );

  setUp(() {
    mockAddressRemoteDataSource = MockAddressRemoteDataSource();
    mockLocationService = MockLocationService();
    addressRepoImpl = AddressRepoImpl(
      mockAddressRemoteDataSource,
      mockLocationService,
    );
  });

  group('AddressRepoImpl - getSavedAddresses', () {
    test('returns SuccessResponse with mapped List<AddressEntity>', () async {
      final mockSavedResponse = SavedAddressesResponse(
        data: [
          AddressDto(
            id: 'addr_1',
            recipientName: 'Ahmed Hassan',
            recipientPhone: '01000000000',
            addressLine: 'Street 9, Maadi',
            cityId: 'Cairo',
            areaId: 'Maadi',
            lat: 29.96,
            lng: 31.25,
            label: 'Home',
          ),
        ],
      );

      when(mockAddressRemoteDataSource.getSavedAddresses()).thenAnswer(
            (_) async => SuccessResponse<SavedAddressesResponse>(mockSavedResponse),
      );

      final result = await addressRepoImpl.getSavedAddresses();

      expect(result, isA<SuccessResponse<List<AddressEntity>>>());
      final successResult = result as SuccessResponse<List<AddressEntity>>;
      expect(successResult.data.first.id, 'addr_1');
      verify(mockAddressRemoteDataSource.getSavedAddresses()).called(1);
    });

    test('returns ErrorResponse when remote data source returns ErrorResponse', () async {
      when(mockAddressRemoteDataSource.getSavedAddresses()).thenAnswer(
            (_) async => ErrorResponse<SavedAddressesResponse>(
          error: 'Failed to fetch saved addresses',
        ),
      );

      final result = await addressRepoImpl.getSavedAddresses();

      expect(result, isA<ErrorResponse<List<AddressEntity>>>());
      verify(mockAddressRemoteDataSource.getSavedAddresses()).called(1);
    });
  });

  group('AddressRepoImpl - addAddress', () {
    const addAddressEntity = AddAddressEntity(
      recipientName: 'Ahmed Hassan',
      recipientPhone: '01000000000',
      addressLine: 'Street 9, Maadi',
      city: 'city_1',
      area: 'area_1',
      lat: 29.96,
      lng: 31.25,
      label: 'Home',
    );

    test('maps AddAddressEntity and returns SuccessResponse', () async {
      final mockAddressDto = AddressDto(
        id: 'addr_100',
        recipientName: 'Ahmed Hassan',
      );

      when(mockAddressRemoteDataSource.addAddress(any)).thenAnswer(
            (_) async => SuccessResponse<CreateAddressResponse>(
          CreateAddressResponse(data: mockAddressDto),
        ),
      );

      final result = await addressRepoImpl.addAddress(addAddressEntity);

      expect(result, isA<SuccessResponse<AddressEntity>>());
      expect((result as SuccessResponse<AddressEntity>).data.id, 'addr_100');
    });

    test('returns ErrorResponse when data is null', () async {
      when(mockAddressRemoteDataSource.addAddress(any)).thenAnswer(
            (_) async => SuccessResponse<CreateAddressResponse>(
          CreateAddressResponse(data: null),
        ),
      );

      final result = await addressRepoImpl.addAddress(addAddressEntity);

      expect(result, isA<ErrorResponse<AddressEntity>>());
    });
  });

  group('AddressRepoImpl - getAreasWithCities', () {
    test('returns SuccessResponse with mapped areas', () async {
      final mockAreaResponse = AreasWithCityResponse(
        data: [AreaDto(id: 'area_1', name: 'Nasr City')],
      );

      when(mockAddressRemoteDataSource.getCities()).thenAnswer(
            (_) async => SuccessResponse<AreasWithCityResponse>(mockAreaResponse),
      );

      final result = await addressRepoImpl.getAreasWithCities();

      expect(result, isA<SuccessResponse<List<AreaEntity>>>());
      expect((result as SuccessResponse<List<AreaEntity>>).data.first.id, 'area_1');
    });

    test('returns ErrorResponse when remote call fails', () async {
      when(mockAddressRemoteDataSource.getCities()).thenAnswer(
            (_) async => ErrorResponse<AreasWithCityResponse>(
          errMessage: 'Failed to load cities',
        ),
      );

      final result = await addressRepoImpl.getAreasWithCities();

      expect(result, isA<ErrorResponse<List<AreaEntity>>>());
    });
  });

  group('AddressRepoImpl - setDefaultAddress', () {
    const addressId = 'addr_123';

    test('returns SuccessResponse on success', () async {
      final mockDto = AddressDto(id: addressId, isDefault: true);

      when(mockAddressRemoteDataSource.setDefaultAddress(addressId)).thenAnswer(
            (_) async => SuccessResponse<AddressDto>(mockDto),
      );

      final result = await addressRepoImpl.setDefaultAddress(addressId);

      expect(result, isA<SuccessResponse<AddressEntity>>());
      expect((result as SuccessResponse<AddressEntity>).data.id, addressId);
    });
  });

  group('AddressRepoImpl - getCurrentLocation', () {
    test('returns ErrorResponse when location services are disabled', () async {
      when(mockLocationService.isServiceEnabled()).thenAnswer((_) async => false);

      final result = await addressRepoImpl.getCurrentLocation();

      expect(result, isA<ErrorResponse<LatLng>>());
      expect((result as ErrorResponse<LatLng>).errMessage, 'Location services are disabled');
    });

    test('returns SuccessResponse when coordinates are resolved', () async {
      when(mockLocationService.isServiceEnabled()).thenAnswer((_) async => true);
      when(mockLocationService.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => const LatLng(30.05, 31.36));

      final result = await addressRepoImpl.getCurrentLocation();

      expect(result, isA<SuccessResponse<LatLng>>());
      expect((result as SuccessResponse<LatLng>).data, const LatLng(30.05, 31.36));
    });
  });

  group('AddressRepoImpl - reverseGeocode', () {
    const lat = 30.05;
    const lng = 31.36;

    test('returns SuccessResponse when reverseGeocode succeeds', () async {
      const model = LocationModel(lat: lat, lng: lng, addressLine: 'Street 10');

      when(mockLocationService.reverseGeocode(lat: lat, lng: lng))
          .thenAnswer((_) async => model);

      final result = await addressRepoImpl.reverseGeocode(lat: lat, lng: lng);

      expect(result, isA<SuccessResponse<LocationModel>>());
      expect((result as SuccessResponse<LocationModel>).data, model);
    });

    test('returns ErrorResponse when locationService returns null', () async {
      when(mockLocationService.reverseGeocode(lat: lat, lng: lng))
          .thenAnswer((_) async => null);

      final result = await addressRepoImpl.reverseGeocode(lat: lat, lng: lng);

      expect(result, isA<ErrorResponse<LocationModel>>());
    });
  });
}