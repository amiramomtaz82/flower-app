import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:flower_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'auth_repo_impl_test.mocks.dart';

// Mocking
@GenerateMocks([AuthLocalDataSource, AuthRemoteDataSource])
void main() {
  late AuthRepoImpl authRepoImpl;
  late MockAuthLocalDataSource mockAuthLocalDataSource;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;

  // setup before each test, so mocks/stubs never leak between tests
  setUp(() {
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    authRepoImpl = AuthRepoImpl(
      mockAuthRemoteDataSource,
      mockAuthLocalDataSource,
    );
  });

  // forget password functions (success/failure)
  group('Forget Password Functions Test', () {
    // Test success case
    test('Forget Password Function Test', () async {
      // Arrange
      when(
        mockAuthRemoteDataSource.forgetPassword(email: anyNamed('email')),
      ).thenAnswer(
        (_) async =>
            const MessageResponseModel(message: 'ok', messageLocalized: 'ok'),
      );

      // Act
      final result = await authRepoImpl.forgetPassword(email: 'email');

      // Assert
      expect(result, isA<SuccessResponse<AuthMessageEntity>>());
      expect(
        (result as SuccessResponse<AuthMessageEntity>).data,
        const AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
      );
    });
    // Test failure case
    test('Forget Password Function Test with Exception', () async {
      // Arrange
      when(
        mockAuthRemoteDataSource.forgetPassword(email: anyNamed('email')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act
      final result = await authRepoImpl.forgetPassword(email: 'email');

      // Assert
      expect(result, isA<ErrorResponse<AuthMessageEntity>>());
    });
  });

  // verify otp functions (success/failure)
  group('Verify Otp Function Test', () {
    // Test success case
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

      final result = await authRepoImpl.verifyOtp(
        email: 'email',
        otpCode: '123456',
      );

      expect(result, isA<SuccessResponse<ResetToken>>());
      expect(
        (result as SuccessResponse<ResetToken>).data,
        ResetToken(token: 'token123', expiresAt: DateTime(2026, 1, 1)),
      );
    });

    // Test failure case
    test('returns ErrorResponse when otp verification throws', () async {
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

      final result = await authRepoImpl.verifyOtp(
        email: 'email',
        otpCode: 'wrong',
      );

      expect(result, isA<ErrorResponse<ResetToken>>());
    });
  });

  // reset password functions (success/failure)
  group('Reset Password Function Test', () {
    test('returns SuccessResponse on success', () async {
      // Arrange
      when(
        mockAuthRemoteDataSource.resetPassword(
          resetToken: anyNamed('resetToken'),
          newPassword: anyNamed('newPassword'),
          confirmNewPassword: anyNamed('confirmNewPassword'),
        ),
      ).thenAnswer(
        (_) async =>
            const MessageResponseModel(message: 'ok', messageLocalized: 'ok'),
      );

      // Act
      final result = await authRepoImpl.resetPassword(
        resetToken: 'token123',
        newPassword: 'newPass1',
        confirmNewPassword: 'newPass1',
      );

      // Assert
      expect(result, isA<SuccessResponse<AuthMessageEntity>>());
      expect(
        (result as SuccessResponse<AuthMessageEntity>).data,
        const AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
      );
      verifyNever(mockAuthLocalDataSource.clearAuthData());
    });

    test('returns ErrorResponse when reset fails', () async {
      // Arrange
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

      // Act
      final result = await authRepoImpl.resetPassword(
        resetToken: 'expired',
        newPassword: 'newPass1',
        confirmNewPassword: 'newPass1',
      );

      // Assert
      expect(result, isA<ErrorResponse<AuthMessageEntity>>());
      verifyNever(mockAuthLocalDataSource.clearAuthData());
    });
  });

  // clearAuthData delegates to the local data source
  group('Clear Auth Data Function Test', () {
    test('delegates to AuthLocalDataSource.clearAuthData', () async {
      // Arrange
      when(mockAuthLocalDataSource.clearAuthData()).thenAnswer((_) async {});

      // Act
      await authRepoImpl.clearAuthData();

      // Assert
      verify(mockAuthLocalDataSource.clearAuthData()).called(1);
    });
  });
}
