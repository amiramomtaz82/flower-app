import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([GetProfileUseCase])
void main() {
  late MockGetProfileUseCase mockGetProfileUseCase;
  late ProfileCubit cubit;

  const profile = ProfileEntity(
    name: 'Hadi Heikal',
    email: 'hadi@test.com',
    profileImageUrl: 'avatar.png',
  );

  setUpAll(() {
    provideDummy<BaseResponse<ProfileEntity>>(const SuccessResponse(profile));
  });

  setUp(() {
    mockGetProfileUseCase = MockGetProfileUseCase();
    cubit = ProfileCubit(mockGetProfileUseCase);
  });

  tearDown(() => cubit.close());

  test('starts with an initial resource and no profile', () {
    expect(cubit.state.resource.status, ApiStatus.initial);
    expect(cubit.state.resource.data, isNull);
  });

  // doEvent does not return the load future, so every case listens to the
  // stream instead of awaiting the event
  group('LoadProfile Test', () {
    test('emits loading then the profile on success', () async {
      when(
        mockGetProfileUseCase(),
      ).thenAnswer((_) async => const SuccessResponse(profile));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProfileState>()
              .having((s) => s.resource.isLoading, 'loading', true),
          isA<ProfileState>()
              .having((s) => s.resource.isSuccess, 'success', true)
              .having((s) => s.resource.data, 'data', profile),
        ]),
      );

      cubit.doEvent(LoadProfile());
      await expectation;

      verify(mockGetProfileUseCase()).called(1);
    });

    test('emits loading then the error message when the use case fails', () async {
      when(mockGetProfileUseCase()).thenAnswer(
        (_) async =>
            ErrorResponse<ProfileEntity>(errMessage: 'No internet connection'),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProfileState>()
              .having((s) => s.resource.isLoading, 'loading', true),
          isA<ProfileState>()
              .having((s) => s.resource.isError, 'error', true)
              .having(
                (s) => s.resource.errorMessage,
                'errorMessage',
                'No internet connection',
              )
              .having((s) => s.resource.data, 'data', isNull),
        ]),
      );

      cubit.doEvent(LoadProfile());
      await expectation;
    });

    test('emits an error instead of hanging when the use case throws', () async {
      when(mockGetProfileUseCase()).thenThrow(Exception('unexpected'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProfileState>()
              .having((s) => s.resource.isLoading, 'loading', true),
          isA<ProfileState>()
              .having((s) => s.resource.isError, 'error', true)
              .having(
                (s) => s.resource.errorMessage,
                'errorMessage',
                'Exception: unexpected',
              ),
        ]),
      );

      cubit.doEvent(LoadProfile());
      await expectation;
    });

    test('loading again after an error brings the profile back', () async {
      when(mockGetProfileUseCase()).thenAnswer(
        (_) async => ErrorResponse<ProfileEntity>(errMessage: 'Server error'),
      );
      final failing = expectLater(
        cubit.stream,
        emitsThrough(
          isA<ProfileState>().having((s) => s.resource.isError, 'error', true),
        ),
      );
      cubit.doEvent(LoadProfile());
      await failing;

      // a later stub wins over the earlier one, so the retry succeeds
      when(
        mockGetProfileUseCase(),
      ).thenAnswer((_) async => const SuccessResponse(profile));
      final retrying = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProfileState>()
              .having((s) => s.resource.isLoading, 'loading', true),
          isA<ProfileState>()
              .having((s) => s.resource.isSuccess, 'success', true)
              .having((s) => s.resource.data, 'data', profile),
        ]),
      );
      cubit.doEvent(LoadProfile());
      await retrying;

      verify(mockGetProfileUseCase()).called(2);
    });
  });
}
