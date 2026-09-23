import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart';
import 'package:flower_app/features/auth/data/models/forgot_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/data/models/register_response.dart';
import 'package:flower_app/features/auth/data/models/reset_password_request_model.dart';
import 'package:flower_app/features/auth/data/models/user_dto.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_request_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';


@GenerateMocks([AuthApiClient])
void main() {
  late MockAuthApiClient mockAuthApiClient;
  late AuthRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    mockAuthApiClient = MockAuthApiClient();
    remoteDataSource = AuthRemoteDataSourceImpl(mockAuthApiClient);
  });

  group('AuthRemoteDataSourceImpl login', () {
    final request = LoginRequest(
      email: 'customer@example.com',
      password: 'Password123',
      deviceId: 'device_123',
      fcmToken: 'fcm_token_123',
    );

    test('should call API and return SuccessResponse when login succeeds', () async {
      final response = LoginResponse(
        accessToken: 'real_access_token',
        refreshToken: 'real_refresh_token',
        expiresIn: 900,

        user: UserDto(
          id: '123',
          email: request.email,
          fullName: 'Ahmed Hassan',
          role: 'Customer',
          isActive: true,
        ),
      );

      when(mockAuthApiClient.login(request)).thenAnswer((_) async => response);

      final result = await remoteDataSource.login(request);

      expect(result, isA<SuccessResponse<LoginResponse>>());
      final success = result as SuccessResponse<LoginResponse>;
      expect(success.data, response);
      expect(success.data.accessToken, 'real_access_token');
      expect(success.data.refreshToken, 'real_refresh_token');
      expect(success.data.expiresIn, 900);

      expect(success.data.user?.email, request.email);
      expect(success.data.user?.fullName, 'Ahmed Hassan');
      verify(mockAuthApiClient.login(request)).called(1);
    });

    test('should return ErrorResponse when API throws an exception', () async {
      final exception = Exception('Server error');
      when(mockAuthApiClient.login(request)).thenThrow(exception);

      final result = await remoteDataSource.login(request);

      expect(result, isA<ErrorResponse<LoginResponse>>());
      final error = result as ErrorResponse<LoginResponse>;
      expect(error.error, exception);
      verify(mockAuthApiClient.login(request)).called(1);
    });

    test('should return dummy SuccessResponse when useDummyLogin is true and credentials match', () async {
      remoteDataSource.useDummyLogin = true;

      final result = await remoteDataSource.login(request);

      expect(result, isA<SuccessResponse<LoginResponse>>());
      final success = result as SuccessResponse<LoginResponse>;
      expect(success.data.accessToken, 'dummy_access_token');
      expect(success.data.refreshToken, 'dummy_refresh_token');
      expect(success.data.user?.email, 'customer@example.com');
      verifyZeroInteractions(mockAuthApiClient);
    });

    test('should return dummy ErrorResponse when useDummyLogin is true and credentials fail', () async {
      remoteDataSource.useDummyLogin = true;

      final invalidRequest = LoginRequest(
        email: 'wrong@example.com',
        password: 'wrong_password',
        deviceId: 'device_123',
        fcmToken: 'fcm_token_123',
      );

      final result = await remoteDataSource.login(invalidRequest);

      expect(result, isA<ErrorResponse<LoginResponse>>());
      final error = result as ErrorResponse<LoginResponse>;
      expect(error.errMessage, 'Invalid email or password');
      verifyZeroInteractions(mockAuthApiClient);
    });
  });

  group('AuthRemoteDataSourceImpl signUp', () {
    final request = SignUpRequest(
      firstName: 'Ahmed',
      lastName: 'Hassan',
      email: 'ahmed@example.com',
      password: 'Password123',
      confirmPassword: 'Password123',
      phoneNumber: '01012345678',
      gender: 'Male',
    );

    const response = AuthResponse(
      message: 'User registered successfully',
      messageLocalized: 'تم التسجيل بنجاح',
    );

    test('should delegate signUp request to AuthApiClient.register and return AuthResponse', () async {
      when(mockAuthApiClient.register(request)).thenAnswer((_) async => response);

      final result = await remoteDataSource.signUp(request);

      expect(result, response);
      expect(result.message, 'User registered successfully');
      expect(result.messageLocalized, 'تم التسجيل بنجاح');
      verify(mockAuthApiClient.register(request)).called(1);
    });

    test('should rethrow when AuthApiClient.register throws', () async {
      when(mockAuthApiClient.register(request)).thenThrow(Exception('Registration failed'));

      expect(() => remoteDataSource.signUp(request), throwsException);
      verify(mockAuthApiClient.register(request)).called(1);
    });
  });

  group('AuthRemoteDataSourceImpl forgetPassword', () {
    const email = 'user@example.com';
    const response = MessageResponseModel(
      message: 'OTP sent to email',
      messageLocalized: 'تم إرسال الرمز',
    );

    test('should call AuthApiClient.forgetPassword with ForgotPasswordRequestModel and return response', () async {
      when(
        mockAuthApiClient.forgetPassword(
          argThat(
            predicate<ForgotPasswordRequestModel>((m) => m.email == email),
          ),
        ),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.forgetPassword(email: email);

      expect(result, response);
      expect(result.message, 'OTP sent to email');
      verify(
        mockAuthApiClient.forgetPassword(
          argThat(
            predicate<ForgotPasswordRequestModel>((m) => m.email == email),
          ),
        ),
      ).called(1);
    });
  });

  group('AuthRemoteDataSourceImpl verifyOtp', () {
    const email = 'user@example.com';
    const otpCode = '123456';
    final tokenData = VerifyOtpResponseData(
      resetToken: 'reset_token_xyz',
      expiresAt: DateTime(2026, 1, 1),
    );
    final response = VerifyOtpResponseModel(data: tokenData);

    test('should call AuthApiClient.verifyOtp with VerifyOtpRequestModel and return response.data', () async {
      when(
        mockAuthApiClient.verifyOtp(
          argThat(
            predicate<VerifyOtpRequestModel>((m) => m.email == email && m.otpCode == otpCode),
          ),
        ),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.verifyOtp(email: email, otpCode: otpCode);

      expect(result, tokenData);
      expect(result.resetToken, 'reset_token_xyz');
      verify(
        mockAuthApiClient.verifyOtp(
          argThat(
            predicate<VerifyOtpRequestModel>((m) => m.email == email && m.otpCode == otpCode),
          ),
        ),
      ).called(1);
    });
  });

  group('AuthRemoteDataSourceImpl resetPassword', () {
    const resetToken = 'reset_token_xyz';
    const newPassword = 'NewPassword123';
    const confirmNewPassword = 'NewPassword123';
    const response = MessageResponseModel(
      message: 'Password reset successfully',
      messageLocalized: 'تم تغيير كلمة المرور بنجاح',
    );

    test('should call AuthApiClient.resetPassword with ResetPasswordRequestModel and return response', () async {
      when(
        mockAuthApiClient.resetPassword(
          argThat(
            predicate<ResetPasswordRequestModel>(
                  (m) =>
              m.resetToken == resetToken &&
                  m.newPassword == newPassword &&
                  m.confirmNewPassword == confirmNewPassword,
            ),
          ),
        ),
      ).thenAnswer((_) async => response);

      final result = await remoteDataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      expect(result, response);
      expect(result.message, 'Password reset successfully');
      verify(
        mockAuthApiClient.resetPassword(
          argThat(
            predicate<ResetPasswordRequestModel>(
                  (m) =>
              m.resetToken == resetToken &&
                  m.newPassword == newPassword &&
                  m.confirmNewPassword == confirmNewPassword,
            ),
          ),
        ),
      ).called(1);
    });
  });
}