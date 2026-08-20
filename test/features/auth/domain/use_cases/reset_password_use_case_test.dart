import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/repo/auth_repo.dart';
import 'package:flower_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'reset_password_use_case_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  late ResetPasswordUseCase resetPasswordUseCase;
  late MockAuthRepo mockAuthRepo;

  setUpAll(() {
    provideDummy<BaseResponse<AuthMessageEntity>>(
      const SuccessResponse(AuthMessageEntity(message: '', messageLocalized: '')),
    );
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    resetPasswordUseCase = ResetPasswordUseCase(mockAuthRepo);
  });

  test('clears auth data when resetPassword succeeds', () async {
    // Arrange
    when(
      mockAuthRepo.resetPassword(
        resetToken: anyNamed('resetToken'),
        newPassword: anyNamed('newPassword'),
        confirmNewPassword: anyNamed('confirmNewPassword'),
      ),
    ).thenAnswer(
      (_) async => const SuccessResponse(
        AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
      ),
    );
    when(mockAuthRepo.clearAuthData()).thenAnswer((_) async {});

    // Act
    final result = await resetPasswordUseCase(
      resetToken: 'token123',
      newPassword: 'newPass1',
      confirmNewPassword: 'newPass1',
    );

    // Assert
    expect(result, isA<SuccessResponse<AuthMessageEntity>>());
    verify(mockAuthRepo.clearAuthData()).called(1);
  });

  test('does not clear auth data when resetPassword fails', () async {
    // Arrange
    when(
      mockAuthRepo.resetPassword(
        resetToken: anyNamed('resetToken'),
        newPassword: anyNamed('newPassword'),
        confirmNewPassword: anyNamed('confirmNewPassword'),
      ),
    ).thenAnswer(
      (_) async => ErrorResponse(
        error: DioException(requestOptions: RequestOptions(path: '')),
      ),
    );

    // Act
    final result = await resetPasswordUseCase(
      resetToken: 'expired',
      newPassword: 'newPass1',
      confirmNewPassword: 'newPass1',
    );

    // Assert
    expect(result, isA<ErrorResponse<AuthMessageEntity>>());
    verifyNever(mockAuthRepo.clearAuthData());
  });
}
