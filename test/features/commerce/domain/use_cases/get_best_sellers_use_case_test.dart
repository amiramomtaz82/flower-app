import 'package:flower_app/config/base_response/base_response.dart';
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
    provideDummy<BaseResponse<PaginatedResponse<ProductEntity>>>(
      ErrorResponse(errMessage: 'dummy'),
    );
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

  test('should return SuccessResponse when repo returns SuccessResponse', () async {
    when(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''))
        .thenAnswer((_) async => SuccessResponse(tPaginatedResponse));

    final result = await useCase.call(page: 1, pageSize: 10, sort: '');

    expect(result, isA<SuccessResponse<PaginatedResponse<ProductEntity>>>());
    expect((result as SuccessResponse).data, tPaginatedResponse);
    verify(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''));
    verifyNoMoreInteractions(mockRepo);
  });

  test('should return ErrorResponse when repo returns ErrorResponse', () async {
    when(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''))
        .thenAnswer((_) async => ErrorResponse(errMessage: 'Error'));

    final result = await useCase.call(page: 1, pageSize: 10, sort: '');

    expect(result, isA<ErrorResponse<PaginatedResponse<ProductEntity>>>());
    expect((result as ErrorResponse).errMessage, 'Error');
    verify(mockRepo.getBestSellers(page: 1, pageSize: 10, sort: ''));
    verifyNoMoreInteractions(mockRepo);
  });
}
