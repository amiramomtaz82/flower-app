import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/Address/api/client/address_api_client.dart';
import 'package:flower_app/features/Address/api/data_source/address_remote_data_source_impl.dart';

import 'package:flower_app/features/Address/data/models/addressdto.dart';
import 'package:flower_app/features/Address/data/models/areas_with_city_response.dart';
import 'package:flower_app/features/Address/data/models/create_address_request.dart';
import 'package:flower_app/features/Address/data/models/create_address_response.dart';
import 'package:flower_app/features/Address/data/models/saved_addresses_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'address_remote_data_source_impl_test.mocks.dart';



@GenerateMocks([
  AddressApiClient,
])
void main() {
  late AddressRemoteDataSourceImpl remoteDataSource;
  late MockAddressApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockAddressApiClient();
    remoteDataSource = AddressRemoteDataSourceImpl(mockApiClient);
  });

  group('getSavedAddresses', () {
    test('returns SuccessResponse when API client call succeeds', () async {
      // Arrange
      final mockResponse = SavedAddressesResponse(data: []);
      when(mockApiClient.getSavedAddresses()).thenAnswer(
            (_) async => mockResponse,
      );

      // Act
      final result = await remoteDataSource.getSavedAddresses();

      // Assert
      expect(result, isA<SuccessResponse<SavedAddressesResponse>>());
      final successResult = result as SuccessResponse<SavedAddressesResponse>;
      expect(successResult.data, mockResponse);
      verify(mockApiClient.getSavedAddresses()).called(1);
    });

    test('returns ErrorResponse when API client throws an Exception', () async {
      // Arrange
      final exception = DioException(
        requestOptions: RequestOptions(path: '/addresses'),
        message: 'Network error',
      );
      when(mockApiClient.getSavedAddresses()).thenThrow(exception);

      // Act
      final result = await remoteDataSource.getSavedAddresses();

      // Assert
      expect(result, isA<ErrorResponse<SavedAddressesResponse>>());
      final errorResult = result as ErrorResponse<SavedAddressesResponse>;
      expect(errorResult.error, exception);
      verify(mockApiClient.getSavedAddresses()).called(1);
    });
  });

  group('addAddress', () {
    final request = CreateAddressRequest(
      recipientName: 'Ahmed Hassan',
      phone: '01000000000',
      addressLine: 'Street 9, Maadi',
      cityId: 'city_1',
      areaId: 'area_1',
      latitude: 29.96,
      longitude: 31.25,
      label: 'Home',
    );

    test('returns SuccessResponse when API client call succeeds', () async {
      // Arrange
      final mockResponse = CreateAddressResponse(
        data: AddressDto(
          id: 'addr_1',
          recipientName: 'Ahmed Hassan',
          recipientPhone: '01000000000',
          addressLine: 'Street 9, Maadi',
          cityId: 'city_1',
          areaId: 'area_1',
          lat: 29.96,
          lng: 31.25,
          label: 'Home',
          isDefault: true,
        ),
      );

      when(mockApiClient.addAddress(any)).thenAnswer(
            (_) async => mockResponse,
      );

      // Act
      final result = await remoteDataSource.addAddress(request);

      // Assert
      expect(result, isA<SuccessResponse<CreateAddressResponse>>());
      final successResult = result as SuccessResponse<CreateAddressResponse>;
      expect(successResult.data, mockResponse);
      verify(mockApiClient.addAddress(request)).called(1);
    });

    test('returns ErrorResponse when API client throws an Exception', () async {
      // Arrange
      final exception = DioException(
        requestOptions: RequestOptions(path: '/addresses'),
        message: 'Bad Request',
      );
      when(mockApiClient.addAddress(any)).thenThrow(exception);

      // Act
      final result = await remoteDataSource.addAddress(request);

      // Assert
      expect(result, isA<ErrorResponse<CreateAddressResponse>>());
      final errorResult = result as ErrorResponse<CreateAddressResponse>;
      expect(errorResult.error, exception);
      verify(mockApiClient.addAddress(request)).called(1);
    });
  });

  group('getCities', () {
    test('returns SuccessResponse when API client getAreas succeeds', () async {
      // Arrange
      final mockResponse = AreasWithCityResponse(data: []);
      when(mockApiClient.getAreas()).thenAnswer(
            (_) async => mockResponse,
      );

      // Act
      final result = await remoteDataSource.getCities();

      // Assert
      expect(result, isA<SuccessResponse<AreasWithCityResponse>>());
      final successResult = result as SuccessResponse<AreasWithCityResponse>;
      expect(successResult.data, mockResponse);
      verify(mockApiClient.getAreas()).called(1);
    });

    test('returns ErrorResponse when API client getAreas throws an error', () async {
      // Arrange
      final error = Exception('Failed to fetch areas');
      when(mockApiClient.getAreas()).thenThrow(error);

      // Act
      final result = await remoteDataSource.getCities();

      // Assert
      expect(result, isA<ErrorResponse<AreasWithCityResponse>>());
      final errorResult = result as ErrorResponse<AreasWithCityResponse>;
      expect(errorResult.error, error);
      verify(mockApiClient.getAreas()).called(1);
    });
  });
}