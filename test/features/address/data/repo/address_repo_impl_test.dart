import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/Address/data/data_source/address_remote_data_source.dart';
import 'package:flower_app/features/Address/data/models/addressdto.dart';
import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';
import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/create_address_response.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:flower_app/features/Address/data/repo/address_repo_impl.dart';

import 'package:flower_app/features/Address/domain/entities/add_address_entity.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:flower_app/features/Address/domain/entities/area_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'address_repo_impl_test.mocks.dart';



@GenerateMocks([
  AddressRemoteDataSource,
])
void main() {
  late AddressRepoImpl addressRepoImpl;
  late MockAddressRemoteDataSource mockAddressRemoteDataSource;

  // Provide dummy values required by Mockito for BaseResponse generics
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

  setUp(() {
    mockAddressRemoteDataSource = MockAddressRemoteDataSource();
    addressRepoImpl = AddressRepoImpl(mockAddressRemoteDataSource);
  });

  group('AddressRepoImpl - getSavedAddresses', () {
    test(
      'returns SuccessResponse with mapped List<AddressEntity> on success',
          () async {
        // Arrange
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

        // Act
        final result = await addressRepoImpl.getSavedAddresses();

        // Assert
        expect(result, isA<SuccessResponse<List<AddressEntity>>>());
        final successResult = result as SuccessResponse<List<AddressEntity>>;
        expect(successResult.data.length, 1);
        expect(successResult.data.first.id, 'addr_1');
        expect(successResult.data.first.recipientName, 'Ahmed Hassan');

        verify(mockAddressRemoteDataSource.getSavedAddresses()).called(1);
      },
    );

    test(
      'returns SuccessResponse with empty list when response data is null',
          () async {
        // Arrange
        final mockSavedResponse = SavedAddressesResponse(data: null);

        when(mockAddressRemoteDataSource.getSavedAddresses()).thenAnswer(
              (_) async => SuccessResponse<SavedAddressesResponse>(mockSavedResponse),
        );

        // Act
        final result = await addressRepoImpl.getSavedAddresses();

        // Assert
        expect(result, isA<SuccessResponse<List<AddressEntity>>>());
        final successResult = result as SuccessResponse<List<AddressEntity>>;
        expect(successResult.data, isEmpty);

        verify(mockAddressRemoteDataSource.getSavedAddresses()).called(1);
      },
    );

    test(
      'returns ErrorResponse when remote data source returns ErrorResponse',
          () async {
        // Arrange
        when(mockAddressRemoteDataSource.getSavedAddresses()).thenAnswer(
              (_) async => ErrorResponse<SavedAddressesResponse>(
            error: 'Failed to fetch saved addresses',
          ),
        );

        // Act
        final result = await addressRepoImpl.getSavedAddresses();

        // Assert
        expect(result, isA<ErrorResponse<List<AddressEntity>>>());
        final errorResult = result as ErrorResponse<List<AddressEntity>>;
        expect(errorResult.error, 'Failed to fetch saved addresses');

        verify(mockAddressRemoteDataSource.getSavedAddresses()).called(1);
      },
    );
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

    test(
      'maps AddAddressEntity to CreateAddressRequest and returns SuccessResponse',
          () async {
        // Arrange
        final mockAddressDto = AddressDto(
          id: 'addr_100',
          recipientName: 'Ahmed Hassan',
          recipientPhone: '01000000000',
          addressLine: 'Street 9, Maadi',
          cityId: 'city_1',
          areaId: 'area_1',
          lat: 29.96,
          lng: 31.25,
          label: 'Home',
        );

        when(
          mockAddressRemoteDataSource.addAddress(
            argThat(
              isA<CreateAddressRequest>()
                  .having((r) => r.recipientName, 'recipientName', 'Ahmed Hassan')
                  .having((r) => r.phone, 'phone', '01000000000')
                  .having((r) => r.addressLine, 'addressLine', 'Street 9, Maadi')
                  .having((r) => r.cityId, 'cityId', 'city_1')
                  .having((r) => r.areaId, 'areaId', 'area_1')
                  .having((r) => r.latitude, 'latitude', 29.96)
                  .having((r) => r.longitude, 'longitude', 31.25)
                  .having((r) => r.label, 'label', 'Home'),
            ),
          ),
        ).thenAnswer(
              (_) async => SuccessResponse<CreateAddressResponse>(
            CreateAddressResponse(data: mockAddressDto),
          ),
        );

        // Act
        final result = await addressRepoImpl.addAddress(addAddressEntity);

        // Assert
        expect(result, isA<SuccessResponse<AddressEntity>>());
        final successResult = result as SuccessResponse<AddressEntity>;
        expect(successResult.data.id, 'addr_100');
        expect(successResult.data.recipientName, 'Ahmed Hassan');

        verify(mockAddressRemoteDataSource.addAddress(any)).called(1);
      },
    );

    test(
      'returns ErrorResponse when CreateAddressResponse data is null',
          () async {
        // Arrange
        when(mockAddressRemoteDataSource.addAddress(any)).thenAnswer(
              (_) async => SuccessResponse<CreateAddressResponse>(
            CreateAddressResponse(data: null),
          ),
        );

        // Act
        final result = await addressRepoImpl.addAddress(addAddressEntity);

        // Assert
        expect(result, isA<ErrorResponse<AddressEntity>>());
        final errorResult = result as ErrorResponse<AddressEntity>;
        expect(errorResult.error, 'Missing address data');

        verify(mockAddressRemoteDataSource.addAddress(any)).called(1);
      },
    );

    test(
      'returns ErrorResponse when remote addAddress returns ErrorResponse',
          () async {
        // Arrange
        when(mockAddressRemoteDataSource.addAddress(any)).thenAnswer(
              (_) async => ErrorResponse<CreateAddressResponse>(
            error: 'Server validation error',
          ),
        );

        // Act
        final result = await addressRepoImpl.addAddress(addAddressEntity);

        // Assert
        expect(result, isA<ErrorResponse<AddressEntity>>());
        final errorResult = result as ErrorResponse<AddressEntity>;
        expect(errorResult.error, 'Server validation error');

        verify(mockAddressRemoteDataSource.addAddress(any)).called(1);
      },
    );
  });

  group('AddressRepoImpl - getAreasWithCities', () {
    test(
      'returns SuccessResponse with mapped List<AreaEntity> on success',
          () async {
        // Arrange
        final mockAreaResponse = AreasWithCityResponse(
          data: [
            AreaDto(
              id: 'area_1',
              name: 'Nasr City',
            ),
          ],
        );

        when(mockAddressRemoteDataSource.getCities()).thenAnswer(
              (_) async => SuccessResponse<AreasWithCityResponse>(mockAreaResponse),
        );

        // Act
        final result = await addressRepoImpl.getAreasWithCities();

        // Assert
        expect(result, isA<SuccessResponse<List<AreaEntity>>>());
        final successResult = result as SuccessResponse<List<AreaEntity>>;
        expect(successResult.data.length, 1);
        expect(successResult.data.first.id, 'area_1');

        verify(mockAddressRemoteDataSource.getCities()).called(1);
      },
    );

    test(
      'returns ErrorResponse when AreasWithCityResponse data is null',
          () async {
        // Arrange
        final mockAreaResponse = AreasWithCityResponse(data: null);

        when(mockAddressRemoteDataSource.getCities()).thenAnswer(
              (_) async => SuccessResponse<AreasWithCityResponse>(mockAreaResponse),
        );

        // Act
        final result = await addressRepoImpl.getAreasWithCities();

        // Assert
        expect(result, isA<ErrorResponse<List<AreaEntity>>>());
        final errorResult = result as ErrorResponse<List<AreaEntity>>;
        expect(errorResult.error, 'Areas response is empty');

        verify(mockAddressRemoteDataSource.getCities()).called(1);
      },
    );

    test(
      'returns ErrorResponse when remote getCities returns ErrorResponse',
          () async {
        // Arrange
        when(mockAddressRemoteDataSource.getCities()).thenAnswer(
              (_) async => ErrorResponse<AreasWithCityResponse>(
            errMessage: 'Failed to load cities',
          ),
        );

        // Act
        final result = await addressRepoImpl.getAreasWithCities();

        // Assert
        expect(result, isA<ErrorResponse<List<AreaEntity>>>());
        final errorResult = result as ErrorResponse<List<AreaEntity>>;
        expect(errorResult.error, 'Failed to load cities');

        verify(mockAddressRemoteDataSource.getCities()).called(1);
      },
    );
  });
}