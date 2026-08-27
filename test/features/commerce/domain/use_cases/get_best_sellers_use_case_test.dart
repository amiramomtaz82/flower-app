import 'package:flower_app/core/domain/result.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/repo/commerce_repo.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_best_sellers_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_best_sellers_use_case_test.mocks.dart';

@GenerateMocks([CommerceRepo])
void main() {
  setUpAll(() {
    provideDummy<Result<PaginatedResponse<ProductEntity>>>(const Failure('dummy'));
  });

  late GetBestSellersUseCase useCase;
  late MockCommerceRepo mockRepo;

  setUp(() {
    mockRepo = MockCommerceRepo();
    useCase = GetBestSellersUseCase(mockRepo);
  });

  final tPaginatedResponse = PaginatedResponse<ProductEntity>(
    data: [ProductEntity(id: '1', name: 'Product 1')],
    pagination: PaginationModel(page: 1, pageSize: 10, totalCount: 1),
  );

  test('should return Success when repo returns Success', () async {
    when(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''))
        .thenAnswer((_) async => Success(tPaginatedResponse));

    final result = await useCase.call(page: 1, pageSize: 10, sort: '');

    expect(result, isA<Success<PaginatedResponse<ProductEntity>>>());
    expect((result as Success).data, tPaginatedResponse);
    verify(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''));
    verifyNoMoreInteractions(mockRepo);
  });

  test('should return Failure when repo returns Failure', () async {
    when(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''))
        .thenAnswer((_) async => Failure('Error'));

    final result = await useCase.call(page: 1, pageSize: 10, sort: '');

    expect(result, isA<Failure<PaginatedResponse<ProductEntity>>>());
    expect((result as Failure).message, 'Error');
    verify(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''));
    verifyNoMoreInteractions(mockRepo);
  });
}
