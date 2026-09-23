import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/device/device_id_service_.dart';
import 'package:flower_app/config/notificaions/fcm.dart';

import 'package:flower_app/features/auth/domain/entities/gender.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';

import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';

import 'package:flower_app/features/auth/data/models/user_dto.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:flower_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:flower_app/features/auth/domain/core/result.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([
  AuthLocalDataSource,
  AuthRemoteDataSource,
  DeviceIdService,
  FcmService,
])
void main() {
  late AuthRepoImpl authRepoImpl;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockDeviceIdService mockDeviceIdService;
  late MockFcm mockFcm;

  provideDummy<BaseResponse<LoginResponse>>(
    SuccessResponse<LoginResponse>(
      LoginResponse(
        accessToken: '',
        refreshToken: '',
        expiresIn: 0,

        user: null,
      ),
    ),
  );

  setUp(() {
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockDeviceIdService = MockDeviceIdService();
    mockFcm = MockFcm();
    authRepoImpl = AuthRepoImpl(
      mockAuthRemoteDataSource,
      mockAuthLocalDataSource,
      mockDeviceIdService,
      mockFcm,
    );
  });

  group('AuthRepoImpl login', () {
    const email = 'customer@example.com';
    const password = 'Password123';
    const deviceId = 'device_123';
    const fcmToken = 'fcm_token_123';

    final loginResponse = LoginResponse(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresIn: 900,

      notificationsEnabled: true,
      user: UserDto(
        id: '123',
        email: email,
        fullName: 'Ahmed Hassan',
        role: 'Customer',
        isActive: true,
      ),
    );

    test(
      'should get device ID and FCM token, call remote login, save tokens, user, and notification setting, then return success',
          () async {
        // Arrange
        when(mockDeviceIdService.getDeviceId()).thenAnswer((_) async => deviceId);
        when(mockFcm.getToken()).thenAnswer((_) async => fcmToken);
        when(mockAuthRemoteDataSource.login(any)).thenAnswer(
              (_) async => SuccessResponse<LoginResponse>(loginResponse),
        );
        when(mockAuthLocalDataSource.saveToken(any)).thenAnswer((_) async {});
        when(mockAuthLocalDataSource.saveRefreshToken(any)).thenAnswer((_) async {});
        when(mockAuthLocalDataSource.saveUser(any)).thenAnswer((_) async {});
        when(mockAuthLocalDataSource.saveNotificationsEnabled(any)).thenAnswer((_) async {});

        // Act
        final result = await authRepoImpl.login(email: email, password: password);

        // Assert
        expect(result, isA<SuccessResponse<LoginEntity>>());
        final success = result as SuccessResponse<LoginEntity>;
        expect(success.data.accessToken, 'access_token');

        verify(mockDeviceIdService.getDeviceId()).called(1);
        verify(mockFcm.getToken()).called(1);
        verify(mockAuthRemoteDataSource.login(any)).called(1);
        verify(mockAuthLocalDataSource.saveToken('access_token')).called(1);
        verify(mockAuthLocalDataSource.saveRefreshToken('refresh_token')).called(1);
        verify(mockAuthLocalDataSource.saveUser(loginResponse.user!)).called(1);
        verify(mockAuthLocalDataSource.saveNotificationsEnabled(true)).called(1);
      },
    );

    test(
      'should return ErrorResponse and avoid saving local data when remote login fails',
          () async {
        // Arrange
        when(mockDeviceIdService.getDeviceId()).thenAnswer((_) async => deviceId);
        when(mockFcm.getToken()).thenAnswer((_) async => fcmToken);
        when(mockAuthRemoteDataSource.login(any)).thenAnswer(
              (_) async => ErrorResponse<LoginResponse>(
            errMessage: 'Invalid email or password',
          ),
        );

        // Act
        final result = await authRepoImpl.login(email: email, password: password);

        // Assert
        expect(result, isA<ErrorResponse<LoginEntity>>());
        final error = result as ErrorResponse<LoginEntity>;
        expect(error.errMessage, 'Invalid email or password');

        verify(mockDeviceIdService.getDeviceId()).called(1);
        verify(mockFcm.getToken()).called(1);
        verify(mockAuthRemoteDataSource.login(any)).called(1);
        verifyNever(mockAuthLocalDataSource.saveToken(any));
        verifyNever(mockAuthLocalDataSource.saveRefreshToken(any));
        verifyNever(mockAuthLocalDataSource.saveUser(any));
        verifyNever(mockAuthLocalDataSource.saveNotificationsEnabled(any));
      },
    );

    test(
      'should not save tokens or user when login response contains null authentication data',
          () async {
        // Arrange
        when(mockDeviceIdService.getDeviceId()).thenAnswer((_) async => deviceId);
        when(mockFcm.getToken()).thenAnswer((_) async => fcmToken);

        final responseWithNulls = LoginResponse(
          accessToken: null,
          refreshToken: null,
          expiresIn: 900,

          notificationsEnabled: false,
          user: null,
        );

        when(mockAuthRemoteDataSource.login(any)).thenAnswer(
              (_) async => SuccessResponse<LoginResponse>(responseWithNulls),
        );
        when(mockAuthLocalDataSource.saveNotificationsEnabled(any)).thenAnswer((_) async {});

        // Act
        final result = await authRepoImpl.login(email: email, password: password);

        // Assert
        expect(result, isA<SuccessResponse<LoginEntity>>());
        final success = result as SuccessResponse<LoginEntity>;
        expect(success.data.accessToken, isNull);

        verify(mockDeviceIdService.getDeviceId()).called(1);
        verify(mockFcm.getToken()).called(1);
        verify(mockAuthRemoteDataSource.login(any)).called(1);
        verify(mockAuthLocalDataSource.saveNotificationsEnabled(false)).called(1);
        verifyNever(mockAuthLocalDataSource.saveToken(any));
        verifyNever(mockAuthLocalDataSource.saveRefreshToken(any));
        verifyNever(mockAuthLocalDataSource.saveUser(any));
      },
    );
  });

  group('AuthRepoImpl signUp', () {
    final params = RegisterParams(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      password: 'Password123!',
      confirmPassword: 'Password123!',
      phoneNumber: '01012345678',
      gender:  Gender.male// Adapt to your enum definition if named differently
    );


    test('should return Failure with extracted error message when remote signUp throws', () async {
      // Arrange
      when(mockAuthRemoteDataSource.signUp(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/signup'),
          error: 'Email already in use',
        ),
      );

      // Act
      final result = await authRepoImpl.signUp(params);

      // Assert
      expect(result, isA<Failure<RegisterEntity>>());
      verify(mockAuthRemoteDataSource.signUp(any)).called(1);
    });
  });

  group('Forget Password Functions Test', () {
    test('returns SuccessResponse on success', () async {
      when(mockAuthRemoteDataSource.forgetPassword(email: anyNamed('email'))).thenAnswer(
            (_) async => const MessageResponseModel(message: 'ok', messageLocalized: 'ok'),
      );

      final result = await authRepoImpl.forgetPassword(email: 'email');

      expect(result, isA<SuccessResponse<AuthMessageEntity>>());
      expect(
        (result as SuccessResponse<AuthMessageEntity>).data,
        const AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
      );
    });

    test('returns ErrorResponse when remote call throws DioException', () async {
      when(mockAuthRemoteDataSource.forgetPassword(email: anyNamed('email'))).thenThrow(
        DioException(requestOptions: RequestOptions(path: '')),
      );

      final result = await authRepoImpl.forgetPassword(email: 'email');

      expect(result, isA<ErrorResponse<AuthMessageEntity>>());
    });
  });

  group('Verify Otp Function Test', () {
    test('returns SuccessResponse with ResetToken on success', () async {
      when(
        mockAuthRemoteDataSource.verifyOtp(
          email: anyNamed('email'),
          otpCode: anyNamed('otpCode'),
        ),
      ).thenAnswer(
            (_) async => VerifyOtpResponseData(
          resetToken: 'token123',
          expiresAt: DateTime(2026, 1, 1),
        ),
      );

      final result = await authRepoImpl.verifyOtp(email: 'email', otpCode: '123456');

      expect(result, isA<SuccessResponse<ResetToken>>());
      expect(
        (result as SuccessResponse<ResetToken>).data,
        ResetToken(token: 'token123', expiresAt: DateTime(2026, 1, 1)),
      );
    });

    test('returns ErrorResponse when otp verification throws DioException', () async {
      when(
        mockAuthRemoteDataSource.verifyOtp(
          email: anyNamed('email'),
          otpCode: anyNamed('otpCode'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'invalid otp',
        ),
      );

      final result = await authRepoImpl.verifyOtp(email: 'email', otpCode: 'wrong');

      expect(result, isA<ErrorResponse<ResetToken>>());
    });
  });

  group('Reset Password Function Test', () {
    test('returns SuccessResponse on success', () async {
      when(
        mockAuthRemoteDataSource.resetPassword(
          resetToken: anyNamed('resetToken'),
          newPassword: anyNamed('newPassword'),
          confirmNewPassword: anyNamed('confirmNewPassword'),
        ),
      ).thenAnswer(
            (_) async => const MessageResponseModel(message: 'ok', messageLocalized: 'ok'),
      );

      final result = await authRepoImpl.resetPassword(
        resetToken: 'token123',
        newPassword: 'newPass1',
        confirmNewPassword: 'newPass1',
      );

      expect(result, isA<SuccessResponse<AuthMessageEntity>>());
      expect(
        (result as SuccessResponse<AuthMessageEntity>).data,
        const AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
      );
      verifyNever(mockAuthLocalDataSource.clearAuthData());
    });

    test('returns ErrorResponse when reset fails', () async {
      when(
        mockAuthRemoteDataSource.resetPassword(
          resetToken: anyNamed('resetToken'),
          newPassword: anyNamed('newPassword'),
          confirmNewPassword: anyNamed('confirmNewPassword'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'token expired',
        ),
      );

      final result = await authRepoImpl.resetPassword(
        resetToken: 'expired',
        newPassword: 'newPass1',
        confirmNewPassword: 'newPass1',
      );

      expect(result, isA<ErrorResponse<AuthMessageEntity>>());
      verifyNever(mockAuthLocalDataSource.clearAuthData());
    });
  });

  group('Clear Auth Data Function Test', () {
    test('delegates to AuthLocalDataSource.clearAuthData', () async {
      when(mockAuthLocalDataSource.clearAuthData()).thenAnswer((_) async {});

      await authRepoImpl.clearAuthData();

      verify(mockAuthLocalDataSource.clearAuthData()).called(1);
    });
  });
}