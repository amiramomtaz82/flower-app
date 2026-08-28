import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/domain/repo/commerce_repo.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_product_details_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_product_details_use_case_test.mocks.dart';

@GenerateMocks([CommerceRepo])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<ProductDetailsEntity>>(
      ErrorResponse(errMessage: 'dummy'),
    );
  });

  late GetProductDetailsUseCase useCase;
  late MockCommerceRepo mockRepo;

  setUp(() {
    mockRepo = MockCommerceRepo();
    useCase = GetProductDetailsUseCase(mockRepo);
  });

  final tProductDetails = ProductDetailsEntity(id: '1', name: 'Product 1');

  test('should return SuccessResponse when repo returns SuccessResponse', () async {
    when(mockRepo.getProductDetails('1'))
        .thenAnswer((_) async => SuccessResponse(tProductDetails));

    final result = await useCase.call('1');

    expect(result, isA<SuccessResponse<ProductDetailsEntity>>());
    expect((result as SuccessResponse).data, tProductDetails);
    verify(mockRepo.getProductDetails('1'));
    verifyNoMoreInteractions(mockRepo);
  });

  test('should return ErrorResponse when repo returns ErrorResponse', () async {
    when(mockRepo.getProductDetails('1'))
        .thenAnswer((_) async => ErrorResponse(errMessage: 'Error'));

    final result = await useCase.call('1');

    expect(result, isA<ErrorResponse<ProductDetailsEntity>>());
    expect((result as ErrorResponse).errMessage, 'Error');
    verify(mockRepo.getProductDetails('1'));
    verifyNoMoreInteractions(mockRepo);
  });
}
