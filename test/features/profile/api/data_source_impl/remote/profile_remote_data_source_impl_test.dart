import 'package:flower_app/features/profile/api/client/profile_api_client.dart';
import 'package:flower_app/features/profile/api/data_source_impl/remote/profile_remote_data_source_impl.dart';
import 'package:flower_app/features/profile/data/models/change_password_dto.dart';
import 'package:flower_app/features/profile/data/models/profile_response_model.dart';
import 'package:flower_app/features/profile/data/models/update_profile_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ProfileApiClient])
void main() {
  late MockProfileApiClient mockProfileApiClient;
  late ProfileRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    mockProfileApiClient = MockProfileApiClient();
    remoteDataSource = ProfileRemoteDataSourceImpl(mockProfileApiClient);
  });

  group("getProfile", () {
    final fakeProfile = ProfileResponseModel(
      id: 'user-123',
      fullName: 'Ahmed Hassan',
      email: 'ahmed@example.com',
      phone: '01012345678',
      gender: 'male',
      photoUrl: 'https://example.com/avatar.png',
    );

    test(
      "should return ProfileResponseModel when getProfile is called",
      () async {
        // Arrange
        when(
          mockProfileApiClient.getProfile(),
        ).thenAnswer((_) async => fakeProfile);

        // Act
        final result = await remoteDataSource.getProfile();

        // Assert
        expect(result, equals(fakeProfile));
        verify(mockProfileApiClient.getProfile()).called(1);
        verifyNoMoreInteractions(mockProfileApiClient);
      },
    );

    test("should throw an exception when getProfile fails", () async {
      // Arrange
      when(
        mockProfileApiClient.getProfile(),
      ).thenAnswer((_) => Future.error(Exception('Server error')));

      // Act & Assert
      await expectLater(
        remoteDataSource.getProfile(),
        throwsA(isA<Exception>()),
      );
      verify(mockProfileApiClient.getProfile()).called(1);
      verifyNoMoreInteractions(mockProfileApiClient);
    });
  });

  group("updateProfile", () {
    final updateDto = UpdateProfileRequestDto(
      fullName: 'Ahmed Hassan',
      email: 'ahmed@example.com',
      phoneNumber: '01012345678',
      gender: 'male',
    );

    final updatedProfile = ProfileResponseModel(
      id: 'user-123',
      fullName: 'Ahmed Hassan',
      email: 'ahmed@example.com',
      phone: '01012345678',
      gender: 'male',
      photoUrl: 'https://example.com/avatar.png',
    );

    test(
      "should return ProfileResponseModel when updateProfile is called successfully",
      () async {
        // Arrange
        when(
          mockProfileApiClient.updateProfile(
            fullName: anyNamed('fullName'),
            email: anyNamed('email'),
            phone: anyNamed('phone'),
            gender: anyNamed('gender'),
            photo: anyNamed('photo'),
          ),
        ).thenAnswer((_) async => updatedProfile);

        // Act
        final result = await remoteDataSource.updateProfile(updateDto);

        // Assert
        expect(result, equals(updatedProfile));
        verify(
          mockProfileApiClient.updateProfile(
            fullName: 'Ahmed Hassan',
            email: 'ahmed@example.com',
            phone: '01012345678',
            gender: 'male',
            photo: null,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockProfileApiClient);
      },
    );

    test("should throw an exception when updateProfile fails", () async {
      // Arrange
      when(
        mockProfileApiClient.updateProfile(
          fullName: anyNamed('fullName'),
          email: anyNamed('email'),
          phone: anyNamed('phone'),
          gender: anyNamed('gender'),
          photo: anyNamed('photo'),
        ),
      ).thenAnswer((_) => Future.error(Exception('Update failed')));

      // Act & Assert
      await expectLater(
        remoteDataSource.updateProfile(updateDto),
        throwsA(isA<Exception>()),
      );
      verify(
        mockProfileApiClient.updateProfile(
          fullName: 'Ahmed Hassan',
          email: 'ahmed@example.com',
          phone: '01012345678',
          gender: 'male',
          photo: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockProfileApiClient);
    });
  });

  group("changePassword", () {
    const changePasswordDto = ChangePasswordRequestDto(
      currentPassword: 'oldPassword123',
      newPassword: 'newPassword123',
      confirmPassword: 'newPassword123',
    );

    test(
      "should call changePassword on client when changePassword is called",
      () async {
        // Arrange
        when(
          mockProfileApiClient.changePassword(any),
        ).thenAnswer((_) async => Future.value());

        // Act
        await remoteDataSource.changePassword(changePasswordDto);

        // Assert
        verify(
          mockProfileApiClient.changePassword(changePasswordDto),
        ).called(1);
        verifyNoMoreInteractions(mockProfileApiClient);
      },
    );

    test("should throw an exception when changePassword fails", () async {
      // Arrange
      when(
        mockProfileApiClient.changePassword(any),
      ).thenAnswer((_) => Future.error(Exception('Password change failed')));

      // Act & Assert
      await expectLater(
        remoteDataSource.changePassword(changePasswordDto),
        throwsA(isA<Exception>()),
      );
      verify(mockProfileApiClient.changePassword(changePasswordDto)).called(1);
      verifyNoMoreInteractions(mockProfileApiClient);
    });
  });

  group("logout", () {
    test("should call logout on client when logout is called", () async {
      // Arrange
      when(
        mockProfileApiClient.logout(),
      ).thenAnswer((_) async => Future.value());

      // Act
      await remoteDataSource.logout();

      // Assert
      verify(mockProfileApiClient.logout()).called(1);
      verifyNoMoreInteractions(mockProfileApiClient);
    });

    test("should throw an exception when logout fails", () async {
      // Arrange
      when(
        mockProfileApiClient.logout(),
      ).thenAnswer((_) => Future.error(Exception('Logout failed')));

      // Act & Assert
      await expectLater(remoteDataSource.logout(), throwsA(isA<Exception>()));
      verify(mockProfileApiClient.logout()).called(1);
      verifyNoMoreInteractions(mockProfileApiClient);
    });
  });
}
