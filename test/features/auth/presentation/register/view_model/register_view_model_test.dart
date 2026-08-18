import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/auth/domain/core/result.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_event.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late RegisterViewModel viewModel;

  const params = RegisterParams(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: Gender.male,
  );

  const entity = RegisterEntity(
    message: 'Success',
  );

  setUpAll(() {
    provideDummy<Result<RegisterEntity>>(Success<RegisterEntity>(entity));
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    viewModel = RegisterViewModel(mockRegisterUseCase);
  });

  group('RegisterViewModel (Cubit)', () {
    test('initial state should be Resource.initial() and gender female', () {
      expect(viewModel.state.status.status, ApiStatus.initial);
      expect(viewModel.state.status.isLoading, false);
      expect(viewModel.state.status.data, null);
      expect(viewModel.state.selectedGender, Gender.female);
    });

    blocTest<RegisterViewModel, RegisterState>(
      'should emit new selected gender on SelectGender event',
      build: () => viewModel,
      act: (vm) => vm.doEvent(SelectGender(Gender.male)),
      expect: () => [
        isA<RegisterState>().having((s) => s.selectedGender, 'selectedGender', Gender.male),
      ],
    );

    blocTest<RegisterViewModel, RegisterState>(
      'should emit new field values on UpdateField event',
      build: () => viewModel,
      act: (vm) => vm.doEvent(UpdateField(firstName: 'John', email: 'j@j.com')),
      expect: () => [
        isA<RegisterState>()
            .having((s) => s.firstName, 'firstName', 'John')
            .having((s) => s.email, 'email', 'j@j.com'),
      ],
    );

    blocTest<RegisterViewModel, RegisterState>(
      'should emit [loading, success] when register succeeds',
      build: () {
        when(mockRegisterUseCase.call(params))
            .thenAnswer((_) async => Success(entity));
        return viewModel;
      },
      act: (vm) => vm.doEvent(DoRegister(params)),
      expect: () => [
        isA<RegisterState>().having((s) => s.status.status, 'status', ApiStatus.loading),
        isA<RegisterState>()
            .having((s) => s.status.status, 'status', ApiStatus.success)
            .having((s) => s.status.data, 'data', entity),
      ],
      verify: (_) {
        verify(mockRegisterUseCase.call(params)).called(1);
      },
    );

    blocTest<RegisterViewModel, RegisterState>(
      'should emit [loading, error] when register fails',
      build: () {
        when(mockRegisterUseCase.call(params))
            .thenAnswer((_) async => Failure('Server error'));
        return viewModel;
      },
      act: (vm) => vm.doEvent(DoRegister(params)),
      expect: () => [
        isA<RegisterState>().having((s) => s.status.status, 'status', ApiStatus.loading),
        isA<RegisterState>()
            .having((s) => s.status.status, 'status', ApiStatus.error)
            .having((s) => s.status.errorMessage, 'errMessage', 'Server error'),
      ],
      verify: (_) {
        verify(mockRegisterUseCase.call(params)).called(1);
      },
    );
  });
}
