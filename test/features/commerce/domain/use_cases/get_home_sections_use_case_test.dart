import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/commerce/domain/entities/home_section_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/home_section_type.dart';
import 'package:flower_app/features/commerce/domain/repo/commerce_repo.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_home_sections_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_home_sections_use_case_test.mocks.dart';

@GenerateMocks([CommerceRepo])
void main() {
  late MockCommerceRepo mockCommerceRepo;
  late GetHomeSectionsUseCase useCase;

  const active0 = HomeSectionEntity(
    id: 's0',
    type: HomeSectionType.categories,
    index: 0,
    isActive: true,
  );
  const active2 = HomeSectionEntity(
    id: 's2',
    type: HomeSectionType.bestSeller,
    index: 2,
    isActive: true,
  );
  const inactive1 = HomeSectionEntity(
    id: 's1',
    type: HomeSectionType.occasions,
    index: 1,
    isActive: false,
  );

  setUpAll(() {
    provideDummy<BaseResponse<List<HomeSectionEntity>>>(
      const SuccessResponse(<HomeSectionEntity>[]),
    );
  });

  setUp(() {
    mockCommerceRepo = MockCommerceRepo();
    useCase = GetHomeSectionsUseCase(mockCommerceRepo);
  });

  test('keeps only active sections, sorted by index', () async {
    when(mockCommerceRepo.getHomeSections()).thenAnswer(
      (_) async => const SuccessResponse([active2, inactive1, active0]),
    );

    final result = await useCase();

    expect(result, isA<SuccessResponse<List<HomeSectionEntity>>>());
    expect(
      (result as SuccessResponse<List<HomeSectionEntity>>).data,
      [active0, active2],
    );
  });

  test('passes through an ErrorResponse unchanged', () async {
    when(mockCommerceRepo.getHomeSections()).thenAnswer(
      (_) async => ErrorResponse(errMessage: 'network down'),
    );

    final result = await useCase();

    expect(result, isA<ErrorResponse<List<HomeSectionEntity>>>());
    expect(
      (result as ErrorResponse<List<HomeSectionEntity>>).errMessage,
      'network down',
    );
  });
}
