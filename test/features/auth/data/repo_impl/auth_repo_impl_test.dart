import 'package:flower_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';

import 'package:flower_app/features/auth/domain/entities/login_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
])
void main() {
  provideDummy<BaseResponse<LoginResponse>>(
    SuccessResponse<LoginResponse>(
      LoginResponse(
        accessToken: '',
        refreshToken: '',
        expiresIn: 0,
        role: '',
        user: null,
      ),
    ),
  );
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();

    repo = AuthRepoImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
    );
  });

  group('AuthRepoImpl login', () {
    final request = LoginRequest(
      email: 'customer@example.com',
      password: 'Password123',
    );

    final loginResponse = LoginResponse(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresIn: 900,
      role: 'Customer',
      user: User(
        id: '123',
        email: 'customer@example.com',
        fullName: 'Ahmed Hassan',
        role: 'Customer',
        isActive: true,
      ),
    );

    test(
      'should save tokens and user and return SuccessResponse when remote login succeeds',
          () async {
        // Arrange
        when(mockRemoteDataSource.login(request))
            .thenAnswer(
              (_) async => SuccessResponse<LoginResponse>(
            loginResponse,
          ),
        );

        when(
          mockLocalDataSource.saveToken('access_token'),
        ).thenAnswer((_) async {});

        when(
          mockLocalDataSource.saveRefreshToken('refresh_token'),
        ).thenAnswer((_) async {});

        when(
          mockLocalDataSource.saveUser(loginResponse.user!),
        ).thenAnswer((_) async {});

        // Act
        final result = await repo.login(request);

        // Assert
        expect(
          result,
          isA<SuccessResponse<LoginEntity>>(),
        );

        final success =
        result as SuccessResponse<LoginEntity>;

        expect(
          success.data.accessToken,
          'access_token',
        );

        // Verify remote data source was called
        verify(
          mockRemoteDataSource.login(request),
        ).called(1);

        // Verify access token was saved
        verify(
          mockLocalDataSource.saveToken('access_token'),
        ).called(1);

        // Verify refresh token was saved
        verify(
          mockLocalDataSource.saveRefreshToken('refresh_token'),
        ).called(1);

        // Verify user was saved
        verify(
          mockLocalDataSource.saveUser(loginResponse.user!),
        ).called(1);
      },
    );

    test(
      'should return ErrorResponse and not save anything when remote login fails',
          () async {
        // Arrange
        when(mockRemoteDataSource.login(request))
            .thenAnswer(
              (_) async => ErrorResponse<LoginResponse>(
            errMessage: 'Invalid email or password',
          ),
        );

        // Act
        final result = await repo.login(request);

        // Assert
        expect(
          result,
          isA<ErrorResponse<LoginEntity>>(),
        );

        final error =
        result as ErrorResponse<LoginEntity>;

        expect(
          error.errMessage,
          'Invalid email or password',
        );

        // Remote should be called
        verify(
          mockRemoteDataSource.login(request),
        ).called(1);

        // Nothing should be saved
        verifyNever(
          mockLocalDataSource.saveToken(any),
        );

        verifyNever(
          mockLocalDataSource.saveRefreshToken(any),
        );

        verifyNever(
          mockLocalDataSource.saveUser(any),
        );
      },
    );

    test(
      'should save only available data when access token, refresh token or user is null',
          () async {
        // Arrange
        final responseWithNulls = LoginResponse(
          accessToken: null,
          refreshToken: null,
          expiresIn: 900,
          role: 'Customer',
          user: null,
        );

        when(mockRemoteDataSource.login(request))
            .thenAnswer(
              (_) async => SuccessResponse<LoginResponse>(
            responseWithNulls,
          ),
        );

        // Act
        final result = await repo.login(request);

        // Assert
        expect(
          result,
          isA<SuccessResponse<LoginEntity>>(),
        );

        verify(
          mockRemoteDataSource.login(request),
        ).called(1);

        verifyNever(
          mockLocalDataSource.saveToken(any),
        );

        verifyNever(
          mockLocalDataSource.saveRefreshToken(any),
        );

        verifyNever(
          mockLocalDataSource.saveUser(any),
        );
      },
    );
  });
}