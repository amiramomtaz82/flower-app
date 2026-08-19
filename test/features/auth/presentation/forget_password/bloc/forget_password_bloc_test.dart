import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/ui_action/ui_action.dart';
import 'package:flower_app/core/ui_action/ui_action_dispatcher.dart';
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

// Mocking the three use cases and the ui action dispatcher the bloc depends on
@GenerateMocks([
  ForgetPasswordUseCase,
  VerifyOtpUseCase,
  ResetPasswordUseCase,
  UiActionDispatcher,
])
void main() {
  late ForgetPasswordBloc forgetPasswordBloc;
  late MockForgetPasswordUseCase mockForgetPasswordUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockUiActionDispatcher mockUiActionDispatcher;

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
    mockUiActionDispatcher = MockUiActionDispatcher();
    forgetPasswordBloc = ForgetPasswordBloc(
      mockForgetPasswordUseCase,
      mockVerifyOtpUseCase,
      mockResetPasswordUseCase,
      mockUiActionDispatcher,
    );
  });

  tearDown(() => forgetPasswordBloc.close());

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
                .having((state) => state.step, 'step', ForgetPasswordStep.otp),
          ]),
        );
        forgetPasswordBloc.add(SendResetCodeEvent('email@example.com'));
        await expectation;

        // Assert
        verify(mockForgetPasswordUseCase(email: 'email@example.com')).called(1);
        verifyNever(mockUiActionDispatcher.dispatch(any));
      },
    );
  });

  // resend cooldown, so each tap cannot burn another backend email
  group('Resend Cooldown Test', () {
    test('starts a 30 second cooldown once the code is sent', () async {
      // Arrange
      when(mockForgetPasswordUseCase(email: anyNamed('email'))).thenAnswer(
        (_) async => const SuccessResponse(
          AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
        ),
      );

      // Act
      forgetPasswordBloc.add(SendResetCodeEvent('email@example.com'));
      await forgetPasswordBloc.stream.firstWhere(
        (state) => state.sendCodeStatus == ForgetPasswordStatus.success,
      );

      // Assert
      expect(
        forgetPasswordBloc.state.resendCooldown,
        ForgetPasswordBloc.resendCooldownSeconds,
      );
      expect(forgetPasswordBloc.state.canResend, isFalse);
    });

    test('ignores a resend while the cooldown is still running', () async {
      // Arrange
      when(mockForgetPasswordUseCase(email: anyNamed('email'))).thenAnswer(
        (_) async => const SuccessResponse(
          AuthMessageEntity(message: 'ok', messageLocalized: 'ok'),
        ),
      );
      forgetPasswordBloc.add(SendResetCodeEvent('email@example.com'));
      await forgetPasswordBloc.stream.firstWhere(
        (state) => state.sendCodeStatus == ForgetPasswordStatus.success,
      );

      // Act
      forgetPasswordBloc.add(
        SendResetCodeEvent('email@example.com', isResend: true),
      );
      await pumpEventQueue();

      // Assert
      verify(mockForgetPasswordUseCase(email: 'email@example.com')).called(1);
    });
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
              .having((state) => state.step, 'step', ForgetPasswordStep.email),
        ]),
      );
      forgetPasswordBloc.add(VerifyResetCodeEvent('wrong'));
      await expectation;

      // Assert
      verify(
        mockVerifyOtpUseCase(email: anyNamed('email'), otpCode: 'wrong'),
      ).called(1);
      verifyNever(mockUiActionDispatcher.dispatch(any));
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
                .having((state) => state.step, 'step', ForgetPasswordStep.otp),
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
                .having((state) => state.resetToken, 'resetToken', isNull),
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
        final dispatched = verify(
          mockUiActionDispatcher.dispatch(captureAny),
        ).captured.single;
        expect(dispatched, isA<NavigateAction>());
        expect((dispatched as NavigateAction).routeName, AppRoutes.login);
        expect(dispatched.replace, isTrue);
      },
    );
  });
}
