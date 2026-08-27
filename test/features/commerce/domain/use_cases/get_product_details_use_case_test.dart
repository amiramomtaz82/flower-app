import 'package:flower_app/core/domain/result.dart';
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
    provideDummy<Result<ProductDetailsEntity>>(const Failure('dummy'));
  });

  late GetProductDetailsUseCase useCase;
  late MockCommerceRepo mockRepo;

  setUp(() {
    mockRepo = MockCommerceRepo();
    useCase = GetProductDetailsUseCase(mockRepo);
  });

  final tProductDetails = ProductDetailsEntity(id: '1', name: 'Product 1');

  test('should return Success when repo returns Success', () async {
    when(mockRepo.getProductDetails('1'))
        .thenAnswer((_) async => Success(tProductDetails));

    final result = await useCase.call('1');

    expect(result, isA<Success<ProductDetailsEntity>>());
    expect((result as Success).data, tProductDetails);
    verify(mockRepo.getProductDetails('1'));
    verifyNoMoreInteractions(mockRepo);
  });

  test('should return Failure when repo returns Failure', () async {
    when(mockRepo.getProductDetails('1'))
        .thenAnswer((_) async => Failure('Error'));

    final result = await useCase.call('1');

    expect(result, isA<Failure<ProductDetailsEntity>>());
    expect((result as Failure).message, 'Error');
    verify(mockRepo.getProductDetails('1'));
    verifyNoMoreInteractions(mockRepo);
  });
}
