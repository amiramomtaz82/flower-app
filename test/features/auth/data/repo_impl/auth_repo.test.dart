import 'package:flower_app/config/device/device_id_service_.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flower_app/config/base_response/base_response.dart';

import 'package:flower_app/config/notificaions/fcm.dart';

import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:flower_app/features/auth/data/repo_impl/auth_repo_impl.dart';

import 'package:flower_app/features/auth/domain/entities/login_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
  DeviceIdService,
  Fcm,
])
void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockDeviceIdService mockDeviceIdService;
  late MockFcm mockFcm;

  late AuthRepoImpl repo;
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

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockDeviceIdService = MockDeviceIdService();
    mockFcm = MockFcm();

    repo = AuthRepoImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockDeviceIdService,
      mockFcm,
    );
  });

  group('AuthRepoImpl login', () {
    const email = 'customer@example.com';
    const password = 'Password123';

    const deviceId = 'device_123';
    const fcmToken = 'fcm_token_123';

    final loginResponse = LoginResponse(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      expiresIn: 900,
      role: 'Customer',
      user: User(
        id: '123',
        email: email,
        fullName: 'Ahmed Hassan',
        role: 'Customer',
        isActive: true,
      ),
    );

    test(
      'should get device ID and FCM token, '
          'call remote login, save tokens and user, '
          'and return success',
          () async {
        // Arrange
        when(
          mockDeviceIdService.getDeviceId(),
        ).thenAnswer((_) async => deviceId);

        when(
          mockFcm.getToken(),
        ).thenAnswer((_) async => fcmToken);


        when(
          mockRemoteDataSource.login(any),
        ).thenAnswer(
              (_) async => SuccessResponse<LoginResponse>(
            loginResponse,
          ),
        );

        when(
          mockLocalDataSource.saveToken(any),
        ).thenAnswer((_) async {});

        when(
          mockLocalDataSource.saveRefreshToken(any),
        ).thenAnswer((_) async {});

        when(
          mockLocalDataSource.saveUser(any),
        ).thenAnswer((_) async {});

        // Act
        final result = await repo.login(
          email: email,
          password: password,
        );

        // Assert
        expect(
          result,
          isA<SuccessResponse<LoginEntity>>(),
        );

        final success = result as SuccessResponse<LoginEntity>;

        expect(
          success.data.accessToken,
          'access_token',
        );

        verify(
          mockDeviceIdService.getDeviceId(),
        ).called(1);

        verify(
          mockFcm.getToken(),
        ).called(1);

        verify(
          mockRemoteDataSource.login(any),
        ).called(1);

        verify(
          mockLocalDataSource.saveToken('access_token'),
        ).called(1);

        verify(
          mockLocalDataSource.saveRefreshToken('refresh_token'),
        ).called(1);

        verify(
          mockLocalDataSource.saveUser(loginResponse.user!),
        ).called(1);
      },
    );

    test(
      'should return ErrorResponse and not save anything '
          'when remote login fails',
          () async {
        // Arrange
        when(
          mockDeviceIdService.getDeviceId(),
        ).thenAnswer((_) async => deviceId);

        when(
          mockFcm.getToken(),
        ).thenAnswer((_) async => fcmToken);



        when(
          mockRemoteDataSource.login(any),
        ).thenAnswer(
              (_) async => ErrorResponse<LoginResponse>(
            errMessage: 'Invalid email or password',
          ),
        );

        // Act
        final result = await repo.login(
          email: email,
          password: password,
        );

        // Assert
        expect(
          result,
          isA<ErrorResponse<LoginEntity>>(),
        );

        final error = result as ErrorResponse<LoginEntity>;

        expect(
          error.errMessage,
          'Invalid email or password',
        );

        verify(
          mockDeviceIdService.getDeviceId(),
        ).called(1);

        verify(
          mockFcm.getToken(),
        ).called(1);

        verify(
          mockRemoteDataSource.login(any),
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

    test(
      'should not save tokens or user when login response '
          'contains null authentication data',
          () async {
        // Arrange
        when(
          mockDeviceIdService.getDeviceId(),
        ).thenAnswer((_) async => deviceId);

        when(
          mockFcm.getToken(),
        ).thenAnswer((_) async => fcmToken);

        final expectedRequest = LoginRequest(
          email: email,
          password: password,
          deviceId: deviceId,
          fcmToken: fcmToken,
        );

        final responseWithNulls = LoginResponse(
          accessToken: null,
          refreshToken: null,
          expiresIn: 900,
          role: 'Customer',
          user: null,
        );

        when(
          mockRemoteDataSource.login(any),
        ).thenAnswer(
              (_) async => SuccessResponse<LoginResponse>(
            responseWithNulls,
          ),
        );

        // Act
        final result = await repo.login(
          email: email,
          password: password,
        );

        // Assert
        expect(
          result,
          isA<SuccessResponse<LoginEntity>>(),
        );

        final success = result as SuccessResponse<LoginEntity>;

        expect(
          success.data.accessToken,
          isNull,
        );

        verify(
          mockDeviceIdService.getDeviceId(),
        ).called(1);

        verify(
          mockFcm.getToken(),
        ).called(1);

        verify(
          mockRemoteDataSource.login(any),
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