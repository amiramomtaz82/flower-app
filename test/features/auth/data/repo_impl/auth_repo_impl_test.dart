import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/data/models/register_response.dart';
import 'package:flower_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepoImpl authRepoImpl;

  final params = RegisterParams(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: Gender.male,
  );

  final request = SignUpRequest(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: 'Male',
  );

  final authResponse = AuthResponse(
    data: AuthResponseData(id: '123', isSuccess: true),
    isSuccess: true,
    message: 'Success',
    statusCode: 200,
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    authRepoImpl = AuthRepoImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('AuthRepoImpl', () {
    test('signUp should return SuccessResponse when remote call succeeds', () async {
      when(mockRemoteDataSource.signUp(any))
          .thenAnswer((_) async => authResponse);

      final result = await authRepoImpl.signUp(params);

      expect(result, isA<SuccessResponse<RegisterEntity>>());
      final success = result as SuccessResponse<RegisterEntity>;
      expect(success.data.message, 'Success');
      verify(mockRemoteDataSource.signUp(any)).called(1);
    });

    test('signUp should return ErrorResponse when remote call throws', () async {
      when(mockRemoteDataSource.signUp(any))
          .thenThrow(Exception('Network error'));

      final result = await authRepoImpl.signUp(params);

      expect(result, isA<ErrorResponse<RegisterEntity>>());
      final error = result as ErrorResponse<RegisterEntity>;
      expect(error.errMessage, isNotEmpty);
      verify(mockRemoteDataSource.signUp(any)).called(1);
    });
  });
}
