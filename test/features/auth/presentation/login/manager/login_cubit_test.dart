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
  provideDummy<BaseResponse<LoginEntity>>(
    SuccessResponse<LoginEntity>(
      LoginEntity(
        accessToken: '',
        refreshToken: '',
        expiresIn: 0,
        role: '',
        user: null,
      ),
    ),
  );
  late MockLoginUseCase mockLoginUseCase;
  late LoginCubit cubit;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    cubit = LoginCubit(mockLoginUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  test('should emit loading then success when login succeeds', () async {
    // Arrange
    final loginEntity = LoginEntity(
      // Use your actual LoginEntity fields
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresIn: 900,
      role: 'Customer',
      user: null,
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

    cubit.doEvents(
      EmailChanged('customer@example.com'),
    );

    cubit.doEvents(
      PasswordChanged('Password123'),
    );

    // Act
    cubit.doEvents(LoginSubmitted());

    // Wait for async login
    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    // Assert
    expect(cubit.state.loginResource.isSuccess, true);
    expect(
      cubit.state.loginResource.data,
      loginEntity,
    );

    verify(
      mockLoginUseCase(
        email: 'customer@example.com',
        password: 'Password123',
      ),
    ).called(1);
  });

  test('should emit loading then error when login fails', () async {
    // Arrange
    when(
      mockLoginUseCase(
        email: 'customer@example.com',
        password: 'WrongPassword',
      ),
    ).thenAnswer(
          (_) async => ErrorResponse<LoginEntity>(
        errMessage: 'Invalid email or password',
      ),
    );

    cubit.doEvents(
      EmailChanged('customer@example.com'),
    );

    cubit.doEvents(
      PasswordChanged('WrongPassword'),
    );

    // Act
    cubit.doEvents(LoginSubmitted());

    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    // Assert
    expect(cubit.state.loginResource.isError, true);
    expect(
      cubit.state.loginResource.errorMessage,
      'Invalid email or password',
    );

    verify(
      mockLoginUseCase(
        email: 'customer@example.com',
        password: 'WrongPassword',
      ),
    ).called(1);
  });
}