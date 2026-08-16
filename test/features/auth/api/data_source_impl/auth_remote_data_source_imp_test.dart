import 'package:flower_app/features/auth/api/data_source_impl/remote/auth_remote_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/api/client/auth_api_client.dart';
import 'package:flower_app/features/auth/data/models/login_request.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';

import 'auth_remote_data_source_imp_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
  late MockAuthApiClient mockAuthApiClient;
  late AuthRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    mockAuthApiClient = MockAuthApiClient();

    remoteDataSource = AuthRemoteDataSourceImpl(
      mockAuthApiClient,
    );
  });

  group('AuthRemoteDataSourceImpl login', () {
    test(
      'should call API and return SuccessResponse when login succeeds',
          () async {
        // Arrange

        final request = LoginRequest(
          email: 'customer@example.com',
          password: 'Password123',
          deviceId: 'device_123',
          fcmToken: 'fcm_token_123',
        );

        final response = LoginResponse(
          accessToken: 'real_access_token',
          refreshToken: 'real_refresh_token',
          expiresIn: 900,
          role: 'Customer',
          user: User(
            id: '123',
            email: request.email,
            fullName: 'Ahmed Hassan',
            role: 'Customer',
            isActive: true,
          ),
        );

        when(
          mockAuthApiClient.login(request),
        ).thenAnswer(
              (_) async => response,
        );

        // Act

        final result = await remoteDataSource.login(request);

        // Assert

        expect(
          result,
          isA<SuccessResponse<LoginResponse>>(),
        );

        final success = result as SuccessResponse<LoginResponse>;

        expect(
          success.data,
          response,
        );

        expect(
          success.data.accessToken,
          'real_access_token',
        );

        expect(
          success.data.refreshToken,
          'real_refresh_token',
        );

        expect(
          success.data.expiresIn,
          900,
        );

        expect(
          success.data.role,
          'Customer',
        );

        expect(
          success.data.user?.email,
          request.email,
        );

        expect(
          success.data.user?.fullName,
          'Ahmed Hassan',
        );

        verify(
          mockAuthApiClient.login(request),
        ).called(1);
      },
    );

    test(
      'should return ErrorResponse when API throws an exception',
          () async {
        // Arrange

        final request = LoginRequest(
          email: 'customer@example.com',
          password: 'Password123',
          deviceId: 'device_123',
          fcmToken: 'fcm_token_123',
        );

        final exception = Exception('Server error');

        when(
          mockAuthApiClient.login(request),
        ).thenThrow(exception);

        // Act

        final result = await remoteDataSource.login(request);

        // Assert

        expect(
          result,
          isA<ErrorResponse<LoginResponse>>(),
        );

        final error = result as ErrorResponse<LoginResponse>;

        expect(
          error.error,
          exception,
        );

        verify(
          mockAuthApiClient.login(request),
        ).called(1);
      },
    );
  });
}