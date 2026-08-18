import 'package:flower_app/features/auth/domain/core/result.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flower_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockAuthRepo mockAuthRepo;
  late RegisterUseCase registerUseCase;

  const params = RegisterParams(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: Gender.male,
  );

  const authResponse = Success(
    RegisterEntity(
      message: 'Success',
      messageLocalized: 'نجاح',
    ),
  );

  setUpAll(() {
    provideDummy<Result<RegisterEntity>>(
      Success<RegisterEntity>(RegisterEntity(message: 'dummy')),
    );
  });

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    registerUseCase = RegisterUseCase(mockAuthRepo);
  });

  group('RegisterUseCase', () {
    test('should call signUp on the repository with correct parameters', () async {
      when(mockAuthRepo.signUp(params))
          .thenAnswer((_) async => authResponse);

      final result = await registerUseCase(params);

      expect(result, authResponse);
      verify(mockAuthRepo.signUp(params)).called(1);
    });
  });
}
