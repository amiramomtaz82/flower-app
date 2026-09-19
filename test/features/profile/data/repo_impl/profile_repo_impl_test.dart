import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flower_app/features/profile/data/repo_impl/profile_repo_impl.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([ProfileRemoteDataSource])
void main() {
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late ProfileRepoImpl repo;

  final dioException = DioException(requestOptions: RequestOptions(path: ''));

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repo = ProfileRepoImpl(mockRemoteDataSource);
  });

  group('getProfile', () {
    test('returns SuccessResponse with the mapped entity on success', () async {
      when(mockRemoteDataSource.getProfile()).thenAnswer(
        (_) async => ProfileResponseModel(
          name: 'Hadi Heikal',
          email: 'hadi@test.com',
          profileImageUrl: 'avatar.png',
          gender: 'male',
          phoneNumber: '+201012345678',
        ),
      );

      final result = await repo.getProfile();

      expect(result, isA<SuccessResponse<ProfileEntity>>());
      // gender and phoneNumber are dropped: the entity only keeps what the UI shows
      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        const ProfileEntity(
          name: 'Hadi Heikal',
          email: 'hadi@test.com',
          profileImageUrl: 'avatar.png',
        ),
      );
      verify(mockRemoteDataSource.getProfile()).called(1);
    });

    test('returns ErrorResponse when the remote call throws', () async {
      when(mockRemoteDataSource.getProfile()).thenThrow(dioException);

      final result = await repo.getProfile();

      expect(result, isA<ErrorResponse<ProfileEntity>>());
    });

    test('falls back to the generic message for a non-Dio error', () async {
      when(
        mockRemoteDataSource.getProfile(),
      ).thenThrow(Exception('unexpected parse failure'));

      final result = await repo.getProfile();

      expect(result, isA<ErrorResponse<ProfileEntity>>());
      expect(
        (result as ErrorResponse<ProfileEntity>).errMessage,
        AppStrings.somethingWentWrong,
      );
    });
  });
}
