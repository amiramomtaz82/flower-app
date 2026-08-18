import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart';
import 'package:flower_app/features/auth/data/models/message_response_model.dart';
import 'package:flower_app/features/auth/data/models/verify_otp_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
  late AuthRemoteDataSourceImpl authRemoteDataSourceImpl;
  late MockAuthApiClient mockAuthApiClient;

  setUp(() {
    mockAuthApiClient = MockAuthApiClient();
    authRemoteDataSourceImpl = AuthRemoteDataSourceImpl(mockAuthApiClient);
  });

  group('forgetPassword', () {
    test(
      'builds the request with the given email and returns the response',
      () async {
        // Arrange
        const fakeResponse = MessageResponseModel(
          message: 'ok',
          messageLocalized: 'ok',
        );
        when(
          mockAuthApiClient.forgetPassword(captureAny),
        ).thenAnswer((_) async => fakeResponse);

        // Act
        final result = await authRemoteDataSourceImpl.forgetPassword(
          email: 'test@test.com',
        );

        // Assert
        expect(result, same(fakeResponse));
        final requestSent = verify(
          mockAuthApiClient.forgetPassword(captureAny),
        ).captured.single;
        expect(requestSent.email, 'test@test.com');
      },
    );
  });

  group('verifyOtp', () {
    test('builds the request and unwraps the data from the envelope', () async {
      // Arrange
      final fakeVm = VerifyOtpResponseData(
        resetToken: 'reset-token-123',
        expiresAt: DateTime(2026, 1, 1),
      );
      when(
        mockAuthApiClient.verifyOtp(captureAny),
      ).thenAnswer((_) async => VerifyOtpResponseModel(data: fakeVm));

      // Act
      final result = await authRemoteDataSourceImpl.verifyOtp(
        email: 'test@test.com',
        otpCode: '123456',
      );

      // Assert — must be the unwrapped Vm, not the envelope
      expect(result, same(fakeVm));
      final requestSent = verify(
        mockAuthApiClient.verifyOtp(captureAny),
      ).captured.single;
      expect(requestSent.email, 'test@test.com');
      expect(requestSent.otpCode, '123456');
    });
  });

  group('resetPassword', () {
    test(
      'builds the request with all three fields and returns the response',
      () async {
        // Arrange
        const fakeResponse = MessageResponseModel(
          message: 'ok',
          messageLocalized: 'ok',
        );
        when(
          mockAuthApiClient.resetPassword(captureAny),
        ).thenAnswer((_) async => fakeResponse);

        // Act
        final result = await authRemoteDataSourceImpl.resetPassword(
          resetToken: 'reset-token-123',
          newPassword: 'newPass1',
          confirmNewPassword: 'newPass1',
        );

        // Assert
        expect(result, same(fakeResponse));
        final requestSent = verify(
          mockAuthApiClient.resetPassword(captureAny),
        ).captured.single;
        expect(requestSent.resetToken, 'reset-token-123');
        expect(requestSent.newPassword, 'newPass1');
        expect(requestSent.confirmNewPassword, 'newPass1');
      },
    );
  });
}
