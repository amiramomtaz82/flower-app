import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flower_app/features/notifications/domain/usecase/set_device_notifications_use_case.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flower_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flower_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([
  GetProfileUseCase,
  UpdateProfileUseCase,
  LogoutUseCase,
  ChangePasswordUseCase,
  SetDeviceNotificationsUseCase,
  AuthRepo,
])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<ProfileEntity>>(
      ErrorResponse(errMessage: 'dummy'),
    );
    provideDummy<BaseResponse<void>>(
      ErrorResponse(errMessage: 'dummy'),
    );
  });

  late MockGetProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockSetDeviceNotificationsUseCase mockSetDeviceNotificationsUseCase;
  late MockAuthRepo mockAuthRepo;
  late ProfileCubit cubit;

  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateProfileUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockSetDeviceNotificationsUseCase = MockSetDeviceNotificationsUseCase();
    mockAuthRepo = MockAuthRepo();

    when(mockAuthRepo.getNotificationsEnabled()).thenAnswer((_) async => true);

    cubit = ProfileCubit(
      mockGetProfileUseCase,
      mockUpdateProfileUseCase,
      mockLogoutUseCase,
      mockChangePasswordUseCase,
      mockSetDeviceNotificationsUseCase,
      mockAuthRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tProfile = ProfileEntity(
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phoneNumber: '01012345678',
    gender: 'male',
    profileImageUrl: 'https://example.com/avatar.png',
  );

  test('initial state should have all resources in initial status', () {
    expect(cubit.state.resource.isLoading, false);
    expect(cubit.state.resource.isSuccess, false);
    expect(cubit.state.resource.isError, false);
    expect(cubit.state.updateProfileResource.isLoading, false);
    expect(cubit.state.logoutResource.isLoading, false);
    expect(cubit.state.changePasswordResource.isLoading, false);
  });

  group('LoadProfile', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, success] when GetProfileUseCase succeeds',
      build: () {
        when(mockGetProfileUseCase())
            .thenAnswer((_) async => const SuccessResponse(tProfile));
        return cubit;
      },
      act: (c) => c.doEvent(LoadProfile()),
      expect: () => [
        predicate<ProfileState>((s) => s.resource.isLoading),
        predicate<ProfileState>(
          (s) => s.resource.isSuccess && s.resource.data == tProfile,
        ),
      ],
      verify: (_) {
        verify(mockGetProfileUseCase()).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, error] when GetProfileUseCase fails',
      build: () {
        when(mockGetProfileUseCase()).thenAnswer(
          (_) async => ErrorResponse(errMessage: 'Failed to load profile'),
        );
        return cubit;
      },
      act: (c) => c.doEvent(LoadProfile()),
      expect: () => [
        predicate<ProfileState>((s) => s.resource.isLoading),
        predicate<ProfileState>(
          (s) =>
              s.resource.isError &&
              s.resource.errorMessage == 'Failed to load profile',
        ),
      ],
      verify: (_) {
        verify(mockGetProfileUseCase()).called(1);
      },
    );
  });

  group('UpdateProfile', () {
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

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, success] when UpdateProfileUseCase succeeds',
      build: () {
        when(mockUpdateProfileUseCase(updateParams))
            .thenAnswer((_) async => const SuccessResponse(updatedProfile));
        return cubit;
      },
      act: (c) => c.doEvent(UpdateProfile(updateParams)),
      expect: () => [
        predicate<ProfileState>((s) => s.updateProfileResource.isLoading),
        predicate<ProfileState>(
          (s) =>
              s.updateProfileResource.isSuccess &&
              s.updateProfileResource.data == updatedProfile &&
              s.resource.data == updatedProfile,
        ),
      ],
      verify: (_) {
        verify(mockUpdateProfileUseCase(updateParams)).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, error] when UpdateProfileUseCase fails',
      build: () {
        when(mockUpdateProfileUseCase(updateParams)).thenAnswer(
          (_) async => ErrorResponse(errMessage: 'Update profile failed'),
        );
        return cubit;
      },
      act: (c) => c.doEvent(UpdateProfile(updateParams)),
      expect: () => [
        predicate<ProfileState>((s) => s.updateProfileResource.isLoading),
        predicate<ProfileState>(
          (s) =>
              s.updateProfileResource.isError &&
              s.updateProfileResource.errorMessage == 'Update profile failed',
        ),
      ],
      verify: (_) {
        verify(mockUpdateProfileUseCase(updateParams)).called(1);
      },
    );
  });

  group('ChangePasswordEvent', () {
    const changeParams = ChangePasswordParams(
      currentPassword: 'oldPassword',
      newPassword: 'newPassword',
      confirmPassword: 'newPassword',
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, success] when ChangePasswordUseCase succeeds',
      build: () {
        when(mockChangePasswordUseCase(changeParams))
            .thenAnswer((_) async => const SuccessResponse(null));
        return cubit;
      },
      act: (c) => c.doEvent(ChangePasswordEvent(changeParams)),
      expect: () => [
        predicate<ProfileState>((s) => s.changePasswordResource.isLoading),
        predicate<ProfileState>((s) => s.changePasswordResource.isSuccess),
      ],
      verify: (_) {
        verify(mockChangePasswordUseCase(changeParams)).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, error] when ChangePasswordUseCase fails',
      build: () {
        when(mockChangePasswordUseCase(changeParams)).thenAnswer(
          (_) async => ErrorResponse(errMessage: 'Password change error'),
        );
        return cubit;
      },
      act: (c) => c.doEvent(ChangePasswordEvent(changeParams)),
      expect: () => [
        predicate<ProfileState>((s) => s.changePasswordResource.isLoading),
        predicate<ProfileState>(
          (s) =>
              s.changePasswordResource.isError &&
              s.changePasswordResource.errorMessage == 'Password change error',
        ),
      ],
      verify: (_) {
        verify(mockChangePasswordUseCase(changeParams)).called(1);
      },
    );
  });

  group('LogoutEvent', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, success] when LogoutUseCase succeeds',
      build: () {
        when(mockLogoutUseCase()).thenAnswer((_) async => Future.value());
        return cubit;
      },
      act: (c) => c.doEvent(LogoutEvent()),
      expect: () => [
        predicate<ProfileState>((s) => s.logoutResource.isLoading),
        predicate<ProfileState>((s) => s.logoutResource.isSuccess),
      ],
      verify: (_) {
        verify(mockLogoutUseCase()).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [loading, error] when LogoutUseCase throws an exception',
      build: () {
        when(mockLogoutUseCase())
            .thenAnswer((_) => Future.error(Exception('Logout failed')));
        return cubit;
      },
      act: (c) => c.doEvent(LogoutEvent()),
      expect: () => [
        predicate<ProfileState>((s) => s.logoutResource.isLoading),
        predicate<ProfileState>((s) => s.logoutResource.isError),
      ],
      verify: (_) {
        verify(mockLogoutUseCase()).called(1);
      },
    );
  });
}
