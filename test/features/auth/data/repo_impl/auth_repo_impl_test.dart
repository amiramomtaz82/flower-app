import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/data/models/register_response.dart';
import 'package:flower_app/features/auth/data/repo_impl/auth_repo_impl.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepoImpl authRepoImpl;

  final tRequest = SignUpRequest(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: 'Male',
  );

  final tAuthResponse = AuthResponse(
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
      when(mockRemoteDataSource.signUp(tRequest))
          .thenAnswer((_) async => tAuthResponse);

      final result = await authRepoImpl.signUp(tRequest);

      expect(result, isA<SuccessResponse<RegisterEntity>>());
      final success = result as SuccessResponse<RegisterEntity>;
      expect(success.data.firstName, 'Amgad');
      expect(success.data.lastName, 'Eid');
      expect(success.data.email, 'amgad@gmail.com');
      expect(success.data.phoneNumber, '01013239659');
      expect(success.data.gender, 'Male');
      verify(mockRemoteDataSource.signUp(tRequest)).called(1);
    });

    test('signUp should return ErrorResponse when remote call throws', () async {
      when(mockRemoteDataSource.signUp(tRequest))
          .thenThrow(Exception('Network error'));

      final result = await authRepoImpl.signUp(tRequest);

      expect(result, isA<ErrorResponse<RegisterEntity>>());
      final error = result as ErrorResponse<RegisterEntity>;
      expect(error.errMessage, isNotEmpty);
      verify(mockRemoteDataSource.signUp(tRequest)).called(1);
    });

    test('signUp should map request fields to entity correctly', () async {
      when(mockRemoteDataSource.signUp(tRequest))
          .thenAnswer((_) async => tAuthResponse);

      final result = await authRepoImpl.signUp(tRequest);

      final success = result as SuccessResponse<RegisterEntity>;
      expect(success.data.firstName, tRequest.firstName);
      expect(success.data.lastName, tRequest.lastName);
      expect(success.data.email, tRequest.email);
      expect(success.data.password, tRequest.password);
      expect(success.data.confirmPassword, tRequest.confirmPassword);
      expect(success.data.phoneNumber, tRequest.phoneNumber);
      expect(success.data.gender, tRequest.gender);
    });
  });
}
