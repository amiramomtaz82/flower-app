import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_events.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:flower_app/features/notifications/domain/usecase/sync_fcm_token_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_cubit_test.mocks.dart';

class FakeSyncFcmTokenUseCase extends Fake implements SyncFcmTokenUseCase {
  bool wasCalled = false;

  @override
  Future<void> call() async {
    wasCalled = true;
  }
}

@GenerateMocks([LoginUseCase])
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late FakeSyncFcmTokenUseCase fakeSyncFcmTokenUseCase;
  late LoginCubit cubit;

  const validEmail = 'customer@example.com';
  const validPassword = 'Password123';

  final loginEntity = LoginEntity(
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
    expiresIn: 900,
    user: null,
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    fakeSyncFcmTokenUseCase = FakeSyncFcmTokenUseCase();
    cubit = LoginCubit(mockLoginUseCase, fakeSyncFcmTokenUseCase);

    provideDummy<BaseResponse<LoginEntity>>(
      SuccessResponse<LoginEntity>(loginEntity),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Initial State', () {
    test('should have default initial state', () {
      expect(cubit.state, LoginState.initial());
      expect(cubit.state.email, '');
      expect(cubit.state.password, '');
      expect(cubit.state.isValid, false);
      expect(cubit.state.obscurePassword, true);
      expect(cubit.state.loginResource.status, ApiStatus.initial);
    });
  });

  group('PasswordVisibilityChanged Event', () {
    test('should toggle obscurePassword state when triggered', () {
      expect(cubit.state.obscurePassword, true);

      cubit.doEvents(PasswordVisibilityChanged());
      expect(cubit.state.obscurePassword, false);

      cubit.doEvents(PasswordVisibilityChanged());
      expect(cubit.state.obscurePassword, true);
    });
  });

  group('EmailChanged and PasswordChanged Form Validation Events', () {
    test('should update email and keep isValid false when password is missing', () async {
      await cubit.doEvents(EmailChanged(validEmail));

      expect(cubit.state.email, validEmail);
      expect(cubit.state.isValid, false);
    });

    test('should update password and keep isValid false when email is invalid', () async {
      await cubit.doEvents(EmailChanged('invalid-email'));
      await cubit.doEvents(PasswordChanged(validPassword));

      expect(cubit.state.email, 'invalid-email');
      expect(cubit.state.password, validPassword);
      expect(cubit.state.isValid, false);
    });

    test('should set isValid to true when both email and password are valid', () async {
      await cubit.doEvents(EmailChanged(validEmail));
      await cubit.doEvents(PasswordChanged(validPassword));

      expect(cubit.state.email, validEmail);
      expect(cubit.state.password, validPassword);
      expect(cubit.state.isValid, true);
    });
  });

  group('LoginSubmitted Event', () {
    test('should emit error and not call use case when form is invalid', () async {
      // Act: Submit without setting valid email and password
      await cubit.doEvents(LoginSubmitted());

      // Assert
      expect(cubit.state.loginResource.isError, true);
      expect(cubit.state.loginResource.errorMessage, AppStrings.pleaseFill);
      expect(fakeSyncFcmTokenUseCase.wasCalled, isFalse);
      verifyZeroInteractions(mockLoginUseCase);
    });

    test('should emit loading then success and trigger token sync when credentials are valid and login succeeds', () async {
      when(
        mockLoginUseCase(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<LoginEntity>(loginEntity),
      );

      await cubit.doEvents(EmailChanged(validEmail));
      await cubit.doEvents(PasswordChanged(validPassword));

      await cubit.doEvents(LoginSubmitted());

      expect(cubit.state.loginResource.isSuccess, true);
      expect(cubit.state.loginResource.data, loginEntity);
      expect(fakeSyncFcmTokenUseCase.wasCalled, isTrue);

      verify(
        mockLoginUseCase(
          email: validEmail,
          password: validPassword,
        ),
      ).called(1);
    });

    test('should emit loading then error and not sync token when credentials are valid but login fails', () async {
      const errorMessage = 'Invalid email or password';

      when(
        mockLoginUseCase(
          email: validEmail,
          password: validPassword,
        ),
      ).thenAnswer(
            (_) async => ErrorResponse<LoginEntity>(errMessage: errorMessage),
      );

      await cubit.doEvents(EmailChanged(validEmail));
      await cubit.doEvents(PasswordChanged(validPassword));

      await cubit.doEvents(LoginSubmitted());

      expect(cubit.state.loginResource.isError, true);
      expect(cubit.state.loginResource.errorMessage, errorMessage);
      expect(fakeSyncFcmTokenUseCase.wasCalled, isFalse);

      verify(
        mockLoginUseCase(
          email: validEmail,
          password: validPassword,
        ),
      ).called(1);
    });
  });
}