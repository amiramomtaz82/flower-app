import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';
import 'package:flower_app/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:flower_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:flower_app/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:flower_app/features/auth/presentation/forget_password/bloc/forget_password_bloc.dart';
import 'package:flower_app/features/auth/presentation/forget_password/bloc/forget_password_event.dart';
import 'package:flower_app/features/auth/presentation/forget_password/bloc/forget_password_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'forget_password_bloc_test.mocks.dart';

// Mocking the three use cases the bloc depends on
@GenerateMocks([ForgetPasswordUseCase, VerifyOtpUseCase, ResetPasswordUseCase])
void main() {
  late ForgetPasswordBloc forgetPasswordBloc;
  late MockForgetPasswordUseCase mockForgetPasswordUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;

  // mockito cannot build a value of a sealed type on its own
  setUpAll(() {
    provideDummy<BaseResponse<AuthMessageEntity>>(
      const SuccessResponse(
        AuthMessageEntity(message: '', messageLocalized: ''),
      ),
    );
    provideDummy<BaseResponse<ResetToken>>(
      SuccessResponse(ResetToken(token: '', expiresAt: DateTime(2026))),
    );
  });

  // setup before each test, so mocks/stubs never leak between tests
  setUp(() {
    mockForgetPasswordUseCase = MockForgetPasswordUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    forgetPasswordBloc = ForgetPasswordBloc(
      mockForgetPasswordUseCase,
      mockVerifyOtpUseCase,
      mockResetPasswordUseCase,
    );
  });

  tearDown(() => forgetPasswordBloc.close());

  // The reset password tests need a token in state first, which only the
  // verify step can put there.
  Future<void> obtainResetToken({required DateTime expiresAt}) async {
    when(
      mockVerifyOtpUseCase(
        email: anyNamed('email'),
        otpCode: anyNamed('otpCode'),
      ),
    ).thenAnswer(
      (_) async =>
          SuccessResponse(ResetToken(token: 'token123', expiresAt: expiresAt)),
    );
    forgetPasswordBloc.add(VerifyResetCodeEvent('123456'));
    await forgetPasswordBloc.stream.firstWhere(
      (state) => state.verifyCodeStatus == ForgetPasswordStatus.success,
    );
  }

  // States are matched field by field rather than compared whole, because
  // ForgetPasswordUiAction has no `==` and is part of the state's props.

  // send reset code function (success case)
  group('Send Reset Code Function Test', () {
    test(
      'emits loading then success and navigates to the OTP screen',
      () async {
        // Arrange
        when(mockForgetPasswordUseCase(email: anyNamed('email'))).thenAnswer(
          (_) async => const SuccessResponse(
            AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
          ),
        );

        // Act
        final expectation = expectLater(
          forgetPasswordBloc.stream,
          emitsInOrder([
            isA<ForgetPasswordState>()
                .having(
                  (state) => state.sendCodeStatus,
                  'sendCodeStatus',
                  ForgetPasswordStatus.loading,
                )
                .having((state) => state.email, 'email', 'email@example.com'),
            isA<ForgetPasswordState>()
                .having(
                  (state) => state.sendCodeStatus,
                  'sendCodeStatus',
                  ForgetPasswordStatus.success,
                )
                .having(
                  (state) => state.uiAction.type,
                  'uiAction.type',
                  ForgetPasswordUiActionType.goToOtp,
                ),
          ]),
        );
        forgetPasswordBloc.add(SendResetCodeEvent('email@example.com'));
        await expectation;

        // Assert
        verify(mockForgetPasswordUseCase(email: 'email@example.com')).called(1);
      },
    );
  });

  // verify reset code function (failure case)
  group('Verify Reset Code Function Test', () {
    test('shows the failure inline without firing a UI action', () async {
      // Arrange
      when(
        mockVerifyOtpUseCase(
          email: anyNamed('email'),
          otpCode: anyNamed('otpCode'),
        ),
      ).thenAnswer(
        (_) async => ErrorResponse(
          error: DioException(requestOptions: RequestOptions(path: '')),
          errMessage: AppStrings.invalidCode,
        ),
      );

      // Act
      final expectation = expectLater(
        forgetPasswordBloc.stream,
        emitsInOrder([
          isA<ForgetPasswordState>().having(
            (state) => state.verifyCodeStatus,
            'verifyCodeStatus',
            ForgetPasswordStatus.loading,
          ),
          isA<ForgetPasswordState>()
              .having(
                (state) => state.verifyCodeStatus,
                'verifyCodeStatus',
                ForgetPasswordStatus.error,
              )
              .having(
                (state) => state.otpErrorMessage,
                'otpErrorMessage',
                isNotNull,
              )
              .having((state) => state.resetToken, 'resetToken', isNull)
              .having(
                (state) => state.uiAction.type,
                'uiAction.type',
                ForgetPasswordUiActionType.none,
              ),
        ]),
      );
      forgetPasswordBloc.add(VerifyResetCodeEvent('wrong'));
      await expectation;

      // Assert
      verify(
        mockVerifyOtpUseCase(email: anyNamed('email'), otpCode: 'wrong'),
      ).called(1);
    });
  });

  // reset password function (expired token / success cases)
  group('Reset Password Function Test', () {
    test(
      'routes back to the OTP screen without calling the use case when the '
      'reset token expired',
      () async {
        // Arrange
        await obtainResetToken(expiresAt: DateTime(2020, 1, 1));

        // Act
        final expectation = expectLater(
          forgetPasswordBloc.stream,
          emitsInOrder([
            isA<ForgetPasswordState>()
                .having(
                  (state) => state.resetStatus,
                  'resetStatus',
                  ForgetPasswordStatus.initial,
                )
                .having(
                  (state) => state.verifyCodeStatus,
                  'verifyCodeStatus',
                  ForgetPasswordStatus.error,
                )
                .having(
                  (state) => state.errorMessage,
                  'errorMessage',
                  AppStrings.resetSessionExpired,
                )
                .having((state) => state.resetToken, 'resetToken', isNull)
                .having(
                  (state) => state.uiAction.type,
                  'uiAction.type',
                  ForgetPasswordUiActionType.goToOtp,
                ),
          ]),
        );
        forgetPasswordBloc.add(ResetPasswordEvent('newPass1', 'newPass1'));
        await expectation;

        // Assert
        verifyNever(
          mockResetPasswordUseCase(
            resetToken: anyNamed('resetToken'),
            newPassword: anyNamed('newPassword'),
            confirmNewPassword: anyNamed('confirmNewPassword'),
          ),
        );
      },
    );

    test(
      'clears the reset token and routes to login on a successful reset',
      () async {
        // Arrange
        await obtainResetToken(expiresAt: DateTime(2030, 1, 1));
        when(
          mockResetPasswordUseCase(
            resetToken: anyNamed('resetToken'),
            newPassword: anyNamed('newPassword'),
            confirmNewPassword: anyNamed('confirmNewPassword'),
          ),
        ).thenAnswer(
          (_) async => const SuccessResponse(
            AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
          ),
        );

        // Act
        final expectation = expectLater(
          forgetPasswordBloc.stream,
          emitsInOrder([
            isA<ForgetPasswordState>().having(
              (state) => state.resetStatus,
              'resetStatus',
              ForgetPasswordStatus.loading,
            ),
            isA<ForgetPasswordState>()
                .having(
                  (state) => state.resetStatus,
                  'resetStatus',
                  ForgetPasswordStatus.success,
                )
                .having((state) => state.resetToken, 'resetToken', isNull)
                .having(
                  (state) => state.uiAction.type,
                  'uiAction.type',
                  ForgetPasswordUiActionType.goToLogin,
                ),
          ]),
        );
        forgetPasswordBloc.add(ResetPasswordEvent('newPass1', 'newPass1'));
        await expectation;

        // Assert
        verify(
          mockResetPasswordUseCase(
            resetToken: 'token123',
            newPassword: 'newPass1',
            confirmNewPassword: 'newPass1',
          ),
        ).called(1);
      },
    );
  });
}
