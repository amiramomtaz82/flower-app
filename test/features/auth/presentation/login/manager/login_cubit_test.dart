import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';
import 'package:flower_app/features/auth/domain/use_cases/login_use_case.dart';

import 'login_cubit_test.mocks.dart';

@GenerateMocks([LoginUseCase])
void main() {
  late MockLoginUseCase mockLoginUseCase;
  late LoginCubit cubit;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    cubit = LoginCubit(mockLoginUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('LoginCubit login tests', () {
    test('should emit success when login succeeds', () async {
      // Arrange

      final loginEntity = LoginEntity(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        expiresIn: 900,
        role: 'Customer',
        user: null,
      );

      provideDummy<BaseResponse<LoginEntity>>(
        SuccessResponse<LoginEntity>(loginEntity),
      );

      when(
        mockLoginUseCase(
          email: 'customer@example.com',
          password: 'Password123',
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<LoginEntity>(
          loginEntity,
        ),
      );

      // Check initial state
      expect(cubit.state.loginResource.isLoading, false);
      expect(cubit.state.loginResource.isSuccess, false);

      // Set email
      await cubit.doEvents(
        EmailChanged('customer@example.com'),
      );

      // Set password
      await cubit.doEvents(
        PasswordChanged('Password123'),
      );

      // Act
      await cubit.doEvents(
        LoginSubmitted(),
      );

      // Assert
      expect(
        cubit.state.loginResource.isSuccess,
        true,
      );

      expect(
        cubit.state.loginResource.data,
        loginEntity,
      );

      verify(
        mockLoginUseCase(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).called(1);
    });

    test('should emit error when login fails', () async {
      // Arrange

      provideDummy<BaseResponse<LoginEntity>>(
        ErrorResponse<LoginEntity>(
          errMessage: 'Invalid email or password',
        ),
      );

      when(
        mockLoginUseCase(
          email: 'customer@example.com',
          password: 'Password123',
        ),
      ).thenAnswer(
            (_) async => ErrorResponse<LoginEntity>(
          errMessage: 'Invalid email or password',
        ),
      );

      // Set email
      await cubit.doEvents(
        EmailChanged('customer@example.com'),
      );

      // Set valid password
      await cubit.doEvents(
        PasswordChanged('Password123'),
      );

      // Act
      await cubit.doEvents(
        LoginSubmitted(),
      );

      // Assert
      expect(
        cubit.state.loginResource.isError,
        true,
      );

      expect(
        cubit.state.loginResource.errorMessage,
        'Invalid email or password',
      );

      verify(
        mockLoginUseCase(
          email: 'customer@example.com',
          password: 'Password123',
        ),
      ).called(1);
    });
  });
}