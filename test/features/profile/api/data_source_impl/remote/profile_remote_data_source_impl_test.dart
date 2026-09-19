import 'package:dio/dio.dart';
import 'package:flower_app/features/profile/api/client/profile_api_client.dart';
import 'package:flower_app/features/profile/api/data_source_impl/remote/profile_remote_data_source_impl.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ProfileApiClient])
void main() {
  late ProfileRemoteDataSourceImpl profileRemoteDataSourceImpl;
  late MockProfileApiClient mockProfileApiClient;

  setUp(() {
    mockProfileApiClient = MockProfileApiClient();
    profileRemoteDataSourceImpl = ProfileRemoteDataSourceImpl(
      mockProfileApiClient,
    );
  });

  group('getProfile', () {
    test('returns the response from the api client', () async {
      // Arrange
      final fakeResponse = ProfileResponseModel(
        name: 'Hadi Heikal',
        email: 'hadi@test.com',
        profileImageUrl: 'avatar.png',
        gender: 'male',
        phoneNumber: '+201012345678',
      );
      when(
        mockProfileApiClient.getProfile(),
      ).thenAnswer((_) async => fakeResponse);

      // Act
      final result = await profileRemoteDataSourceImpl.getProfile();

      // Assert
      expect(result, same(fakeResponse));
      verify(mockProfileApiClient.getProfile()).called(1);
      verifyNoMoreInteractions(mockProfileApiClient);
    });

    test('lets the api client error through so the repo can map it', () async {
      // Arrange
      when(
        mockProfileApiClient.getProfile(),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act & Assert
      await expectLater(
        profileRemoteDataSourceImpl.getProfile(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
