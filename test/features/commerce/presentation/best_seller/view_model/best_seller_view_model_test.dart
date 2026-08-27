import 'package:flower_app/core/domain/result.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_best_sellers_use_case.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_view_model.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'best_seller_view_model_test.mocks.dart';

@GenerateMocks([GetBestSellersUseCase])
void main() {
  setUpAll(() {
    provideDummy<Result<PaginatedResponse<ProductEntity>>>(const Failure('dummy'));
  });

  late BestSellerViewModel viewModel;
  late MockGetBestSellersUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetBestSellersUseCase();
    viewModel = BestSellerViewModel(mockUseCase);
  });

  final tPaginatedResponse = PaginatedResponse<ProductEntity>(
    data: [ProductEntity(id: '1', name: 'Product 1')],
    pagination: PaginationModel(page: 1, pageSize: 10, totalCount: 1),
  );

  test('loadInitial should emit loading then success with data', () async {
    when(mockUseCase.call(
            page: anyNamed('page'),
            pageSize: anyNamed('pageSize'),
            sort: anyNamed('sort')))
        .thenAnswer((_) async => Success(tPaginatedResponse));

    viewModel.doEvent(LoadInitialBestSellers());
    await Future.microtask(() {});
    await Future.microtask(() {});

    expect(viewModel.state.resource.data, isNotEmpty);
    expect(viewModel.state.resource.data!.first.name, 'Product 1');
  });

  test('loadInitial should emit loading then error on failure', () async {
    when(mockUseCase.call(
            page: anyNamed('page'),
            pageSize: anyNamed('pageSize'),
            sort: anyNamed('sort')))
        .thenAnswer((_) async => Failure('Error message'));

    viewModel.doEvent(LoadInitialBestSellers());
    await Future.microtask(() {});
    await Future.microtask(() {});

    expect(viewModel.state.resource.errorMessage, 'Error message');
  });
}
