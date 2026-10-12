import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/profile/data/data_source/remote/profile_remote_data_source.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flower_app/features/profile/data/repo_impl/profile_repo_impl.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([ProfileRemoteDataSource])
void main() {
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late ProfileRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repo = ProfileRepoImpl(mockRemoteDataSource);
  });

  group('getProfile', () {
    final fakeModel = ProfileResponseModel(
      id: 'user-123',
      fullName: 'Ahmed Hassan',
      email: 'ahmed@example.com',
      phone: '01012345678',
      gender: 'male',
      photoUrl: 'https://example.com/avatar.png',
    );

    test(
      'should return SuccessResponse with ProfileEntity when remote call succeeds',
      () async {
        // Arrange
        when(mockRemoteDataSource.getProfile())
            .thenAnswer((_) async => fakeModel);

        // Act
        final result = await repo.getProfile();

        // Assert
        expect(result, isA<SuccessResponse<ProfileEntity>>());
        final success = result as SuccessResponse<ProfileEntity>;
        expect(success.data.name, equals('Ahmed Hassan'));
        expect(success.data.email, equals('ahmed@example.com'));
        expect(success.data.phoneNumber, equals('01012345678'));
        expect(success.data.gender, equals('male'));
        expect(
          success.data.profileImageUrl,
          equals('https://example.com/avatar.png'),
        );
        verify(mockRemoteDataSource.getProfile()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ErrorResponse when remote call throws an exception',
      () async {
        // Arrange
        final exception = Exception('Failed to load profile');
        when(mockRemoteDataSource.getProfile())
            .thenAnswer((_) => Future.error(exception));

        // Act
        final result = await repo.getProfile();

        // Assert
        expect(result, isA<ErrorResponse<ProfileEntity>>());
        verify(mockRemoteDataSource.getProfile()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });

  group('updateProfile', () {
    final updateParams = UpdateProfileParams(
      fullName: 'Sara Ahmed',
      email: 'sara@example.com',
      phoneNumber: '01098765432',
      gender: 'female',
      photoUrl: 'https://example.com/sara.png',
    );

    final updatedModel = ProfileResponseModel(
      id: 'user-123',
      fullName: 'Sara Ahmed',
      email: 'sara@example.com',
      phone: '01098765432',
      gender: 'female',
      photoUrl: 'https://example.com/sara.png',
    );

    test(
      'should return SuccessResponse with updated ProfileEntity when remote call succeeds',
      () async {
        // Arrange
        when(mockRemoteDataSource.updateProfile(any))
            .thenAnswer((_) async => updatedModel);

        // Act
        final result = await repo.updateProfile(updateParams);

        // Assert
        expect(result, isA<SuccessResponse<ProfileEntity>>());
        final success = result as SuccessResponse<ProfileEntity>;
        expect(success.data.name, equals('Sara Ahmed'));
        expect(success.data.email, equals('sara@example.com'));
        expect(success.data.phoneNumber, equals('01098765432'));
        expect(success.data.gender, equals('female'));
        expect(
          success.data.profileImageUrl,
          equals('https://example.com/sara.png'),
        );
        verify(mockRemoteDataSource.updateProfile(any)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ErrorResponse when remote call throws an exception',
      () async {
        // Arrange
        when(mockRemoteDataSource.updateProfile(any))
            .thenAnswer((_) => Future.error(Exception('Update error')));

        // Act
        final result = await repo.updateProfile(updateParams);

        // Assert
        expect(result, isA<ErrorResponse<ProfileEntity>>());
        verify(mockRemoteDataSource.updateProfile(any)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });

  group('changePassword', () {
    final changeParams = ChangePasswordParams(
      currentPassword: 'oldPassword123',
      newPassword: 'newPassword123',
      confirmPassword: 'newPassword123',
    );

    test(
      'should return SuccessResponse(null) when remote call succeeds',
      () async {
        // Arrange
        when(mockRemoteDataSource.changePassword(any))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repo.changePassword(changeParams);

        // Assert
        expect(result, isA<SuccessResponse<void>>());
        verify(mockRemoteDataSource.changePassword(any)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ErrorResponse when remote call throws an exception',
      () async {
        // Arrange
        when(mockRemoteDataSource.changePassword(any))
            .thenAnswer((_) => Future.error(Exception('Password error')));

        // Act
        final result = await repo.changePassword(changeParams);

        // Assert
        expect(result, isA<ErrorResponse<void>>());
        verify(mockRemoteDataSource.changePassword(any)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });

  group('logout', () {
    test(
      'should return SuccessResponse(null) when remote call succeeds',
      () async {
        // Arrange
        when(mockRemoteDataSource.logout())
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repo.logout();

        // Assert
        expect(result, isA<SuccessResponse<void>>());
        verify(mockRemoteDataSource.logout()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ErrorResponse when remote call throws an exception',
      () async {
        // Arrange
        when(mockRemoteDataSource.logout())
            .thenAnswer((_) => Future.error(Exception('Logout error')));

        // Act
        final result = await repo.logout();

        // Assert
        expect(result, isA<ErrorResponse<void>>());
        verify(mockRemoteDataSource.logout()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );
  });
}