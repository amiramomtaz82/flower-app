import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flower_app/features/profile/domain/repos/profile_repo.dart';
import 'package:flower_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_use_cases_test.mocks.dart';

@GenerateMocks([ProfileRepo, AuthRepo])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<ProfileEntity>>(
      ErrorResponse(errMessage: 'dummy'),
    );
    provideDummy<BaseResponse<void>>(
      ErrorResponse(errMessage: 'dummy'),
    );
  });

  late MockProfileRepo mockProfileRepo;
  late MockAuthRepo mockAuthRepo;
  late GetProfileUseCase getProfileUseCase;
  late UpdateProfileUseCase updateProfileUseCase;
  late ChangePasswordUseCase changePasswordUseCase;
  late LogoutUseCase logoutUseCase;

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    mockAuthRepo = MockAuthRepo();
    getProfileUseCase = GetProfileUseCase(mockProfileRepo);
    updateProfileUseCase = UpdateProfileUseCase(mockProfileRepo);
    changePasswordUseCase = ChangePasswordUseCase(mockProfileRepo);
    logoutUseCase = LogoutUseCase(mockAuthRepo);
  });

  const tProfile = ProfileEntity(
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phoneNumber: '01012345678',
    gender: 'male',
    profileImageUrl: 'https://example.com/avatar.png',
  );

  group('GetProfileUseCase', () {
    test('should return SuccessResponse when repo succeeds', () async {
      // Arrange
      when(mockProfileRepo.getProfile())
          .thenAnswer((_) async => const SuccessResponse(tProfile));

      // Act
      final result = await getProfileUseCase();

      // Assert
      expect(result, isA<SuccessResponse<ProfileEntity>>());
      expect((result as SuccessResponse<ProfileEntity>).data, equals(tProfile));
      verify(mockProfileRepo.getProfile()).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });

    test('should return ErrorResponse when repo fails', () async {
      // Arrange
      when(mockProfileRepo.getProfile())
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Error'));

      // Act
      final result = await getProfileUseCase();

      // Assert
      expect(result, isA<ErrorResponse<ProfileEntity>>());
      verify(mockProfileRepo.getProfile()).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });
  });

  group('UpdateProfileUseCase', () {
    const updateParams = UpdateProfileParams(
      fullName: 'Sara Ahmed',
      email: 'sara@example.com',
      phoneNumber: '01098765432',
      gender: 'female',
      photoUrl: 'https://example.com/sara.png',
    );

    const updatedProfile = ProfileEntity(
      name: 'Sara Ahmed',
      email: 'sara@example.com',
      phoneNumber: '01098765432',
      gender: 'female',
      profileImageUrl: 'https://example.com/sara.png',
    );

    test('should return SuccessResponse when repo succeeds', () async {
      // Arrange
      when(mockProfileRepo.updateProfile(updateParams))
          .thenAnswer((_) async => const SuccessResponse(updatedProfile));

      // Act
      final result = await updateProfileUseCase(updateParams);

      // Assert
      expect(result, isA<SuccessResponse<ProfileEntity>>());
      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        equals(updatedProfile),
      );
      verify(mockProfileRepo.updateProfile(updateParams)).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });

    test('should return ErrorResponse when repo fails', () async {
      // Arrange
      when(mockProfileRepo.updateProfile(updateParams))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Update failed'));

      // Act
      final result = await updateProfileUseCase(updateParams);

      // Assert
      expect(result, isA<ErrorResponse<ProfileEntity>>());
      verify(mockProfileRepo.updateProfile(updateParams)).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });
  });

  group('ChangePasswordUseCase', () {
    const changeParams = ChangePasswordParams(
      currentPassword: 'oldPassword',
      newPassword: 'newPassword',
      confirmPassword: 'newPassword',
    );

    test('should return SuccessResponse when repo succeeds', () async {
      // Arrange
      when(mockProfileRepo.changePassword(changeParams))
          .thenAnswer((_) async => const SuccessResponse(null));

      // Act
      final result = await changePasswordUseCase(changeParams);

      // Assert
      expect(result, isA<SuccessResponse<void>>());
      verify(mockProfileRepo.changePassword(changeParams)).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });

    test('should return ErrorResponse when repo fails', () async {
      // Arrange
      when(mockProfileRepo.changePassword(changeParams))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Failed'));

      // Act
      final result = await changePasswordUseCase(changeParams);

      // Assert
      expect(result, isA<ErrorResponse<void>>());
      verify(mockProfileRepo.changePassword(changeParams)).called(1);
      verifyNoMoreInteractions(mockProfileRepo);
    });
  });

  group('LogoutUseCase', () {
    test('should call clearAuthData on AuthRepo', () async {
      // Arrange
      when(mockAuthRepo.clearAuthData())
          .thenAnswer((_) async => Future.value());

      // Act
      await logoutUseCase();

      // Assert
      verify(mockAuthRepo.clearAuthData()).called(1);
      verifyNoMoreInteractions(mockAuthRepo);
    });
  });
}
