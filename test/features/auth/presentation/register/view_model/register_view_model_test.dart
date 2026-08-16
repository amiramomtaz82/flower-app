import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_event.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../helpers/test_helper.mocks.dart';

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late RegisterViewModel viewModel;

  final tRequest = SignUpRequest(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
    phoneNumber: '01013239659',
    gender: 'Male',
  );

  final tEntity = RegisterEntity(
    firstName: 'Amgad',
    lastName: 'Eid',
    email: 'amgad@gmail.com',
    phoneNumber: '01013239659',
    gender: 'Male',
    password: '*Aa123456#',
    confirmPassword: '*Aa123456#',
  );

  setUpAll(() {
    provideDummy<BaseResponse<RegisterEntity>>(SuccessResponse<RegisterEntity>(tEntity));
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    viewModel = RegisterViewModel(mockRegisterUseCase);
  });

  group('RegisterViewModel (Cubit)', () {
    test('initial state should be RegisterState with default values', () {
      expect(viewModel.state, const RegisterState());
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.data, null);
      expect(viewModel.state.errMessage, '');
    });

    blocTest<RegisterViewModel, RegisterState>(
      'should emit [loading, success] when register succeeds',
      build: () {
        when(mockRegisterUseCase.call(tRequest))
            .thenAnswer((_) async => SuccessResponse(tEntity));
        return viewModel;
      },
      act: (vm) => vm.doEvent(DoRegister(tRequest)),
      expect: () => [
        const RegisterState(isLoading: true, errMessage: ''),
        RegisterState(isLoading: false, data: tEntity),
      ],
      verify: (_) {
        verify(mockRegisterUseCase.call(tRequest)).called(1);
      },
    );

    blocTest<RegisterViewModel, RegisterState>(
      'should emit [loading, success with dummy] when register fails (dummy fallback)',
      build: () {
        when(mockRegisterUseCase.call(tRequest))
            .thenAnswer((_) async => ErrorResponse(errMessage: 'Server error'));
        return viewModel;
      },
      act: (vm) => vm.doEvent(DoRegister(tRequest)),
      expect: () => [
        const RegisterState(isLoading: true, errMessage: ''),
        isA<RegisterState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.data, 'data', isNotNull)
            .having((s) => s.data!.firstName, 'firstName', 'Amgad')
            .having((s) => s.data!.email, 'email', 'amgad@gmail.com'),
      ],
      verify: (_) {
        verify(mockRegisterUseCase.call(tRequest)).called(1);
      },
    );
  });
}
