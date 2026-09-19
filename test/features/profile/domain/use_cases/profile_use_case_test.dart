import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/repos/profile_repo.dart';
import 'package:flower_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_use_case_test.mocks.dart';

@GenerateMocks([ProfileRepo])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<ProfileEntity>>(
      ErrorResponse(errMessage: 'dummy'),
    );
  });

  late GetProfileUseCase useCase;
  late MockProfileRepo mockRepo;

  setUp(() {
    mockRepo = MockProfileRepo();
    useCase = GetProfileUseCase(mockRepo);
  });

  const tProfile = ProfileEntity(
    name: 'Hadi Heikal',
    email: 'hadi@test.com',
    profileImageUrl: 'avatar.png',
  );

  test('should return SuccessResponse when repo returns SuccessResponse', () async {
    when(mockRepo.getProfile())
        .thenAnswer((_) async => const SuccessResponse(tProfile));

    final result = await useCase.call();

    expect(result, isA<SuccessResponse<ProfileEntity>>());
    expect((result as SuccessResponse).data, tProfile);
    verify(mockRepo.getProfile());
    verifyNoMoreInteractions(mockRepo);
  });

  test('should return ErrorResponse when repo returns ErrorResponse', () async {
    when(mockRepo.getProfile())
        .thenAnswer((_) async => ErrorResponse(errMessage: 'Error'));

    final result = await useCase.call();

    expect(result, isA<ErrorResponse<ProfileEntity>>());
    expect((result as ErrorResponse).errMessage, 'Error');
    verify(mockRepo.getProfile());
    verifyNoMoreInteractions(mockRepo);
  });
}
