import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flower_app/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'verify_otp_use_case_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  late VerifyOtpUseCase verifyOtpUseCase;
  late MockAuthRepo mockAuthRepo;

  setUpAll(() {
    provideDummy<BaseResponse<ResetToken>>(
      SuccessResponse(ResetToken(token: '', expiresAt: DateTime(2026))),
    );
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    verifyOtpUseCase = VerifyOtpUseCase(mockAuthRepo);
  });

  test('delegates to AuthRepo.verifyOtp and returns SuccessResponse', () async {
    // Arrange
    final resetToken = ResetToken(
      token: 'token123',
      expiresAt: DateTime(2026, 1, 1),
    );
    when(
      mockAuthRepo.verifyOtp(
        email: anyNamed('email'),
        otpCode: anyNamed('otpCode'),
      ),
    ).thenAnswer((_) async => SuccessResponse(resetToken));

    // Act
    final result = await verifyOtpUseCase(
      email: 'email@example.com',
      otpCode: '123456',
    );

    // Assert
    expect(result, isA<SuccessResponse<ResetToken>>());
    expect((result as SuccessResponse<ResetToken>).data, resetToken);
    verify(
      mockAuthRepo.verifyOtp(email: 'email@example.com', otpCode: '123456'),
    ).called(1);
  });

  test('returns ErrorResponse when AuthRepo.verifyOtp fails', () async {
    // Arrange
    when(
      mockAuthRepo.verifyOtp(
        email: anyNamed('email'),
        otpCode: anyNamed('otpCode'),
      ),
    ).thenAnswer(
      (_) async => ErrorResponse(
        error: DioException(requestOptions: RequestOptions(path: '')),
      ),
    );

    // Act
    final result = await verifyOtpUseCase(
      email: 'email@example.com',
      otpCode: 'wrong',
    );

    // Assert
    expect(result, isA<ErrorResponse<ResetToken>>());
  });
}
