import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
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

  final tParams = RegisterParams(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: Gender.male,
  );

  final tEntity = RegisterEntity(
    message: 'Success',
  );

  setUpAll(() {
    provideDummy<BaseResponse<RegisterEntity>>(SuccessResponse<RegisterEntity>(tEntity));
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    viewModel = RegisterViewModel(mockRegisterUseCase);
  });

  group('RegisterViewModel (Cubit)', () {
    test('initial state should be Resource.initial()', () {
      expect(viewModel.state.status, ApiStatus.initial);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.data, null);
    });

    blocTest<RegisterViewModel, RegisterState>(
      'should emit [loading, success] when register succeeds',
      build: () {
        when(mockRegisterUseCase.call(tParams))
            .thenAnswer((_) async => SuccessResponse(tEntity));
        return viewModel;
      },
      act: (vm) => vm.doEvent(DoRegister(tParams)),
      expect: () => [
        isA<RegisterState>().having((s) => s.status, 'status', ApiStatus.loading),
        isA<RegisterState>()
            .having((s) => s.status, 'status', ApiStatus.success)
            .having((s) => s.data, 'data', tEntity),
      ],
      verify: (_) {
        verify(mockRegisterUseCase.call(tParams)).called(1);
      },
    );

    blocTest<RegisterViewModel, RegisterState>(
      'should emit [loading, error] when register fails (dummy fallback removed)',
      build: () {
        when(mockRegisterUseCase.call(tParams))
            .thenAnswer((_) async => ErrorResponse(errMessage: 'Server error'));
        return viewModel;
      },
      act: (vm) => vm.doEvent(DoRegister(tParams)),
      expect: () => [
        isA<RegisterState>().having((s) => s.status, 'status', ApiStatus.loading),
        isA<RegisterState>()
            .having((s) => s.status, 'status', ApiStatus.error)
            .having((s) => s.errorMessage, 'errMessage', 'Server error'),
      ],
      verify: (_) {
        verify(mockRegisterUseCase.call(tParams)).called(1);
      },
    );
  });
}
