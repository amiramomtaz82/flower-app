import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/domain/result.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_product_details_use_case.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_state.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_event.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_details_view_model_test.mocks.dart';

@GenerateMocks([GetProductDetailsUseCase])
void main() {
  setUpAll(() {
    provideDummy<Result<ProductDetailsEntity>>(const Failure('dummy'));
  });

  late ProductDetailsViewModel viewModel;
  late MockGetProductDetailsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetProductDetailsUseCase();
    viewModel = ProductDetailsViewModel(mockUseCase);
  });

  final tProductDetails = ProductDetailsEntity(id: '1', name: 'Product 1');

  test('initial state should be Resource.initial() and image index 0', () {
    expect(viewModel.state.resource.status, ApiStatus.initial);
    expect(viewModel.state.currentImageIndex, 0);
  });

  test('loadDetails should emit loading then success', () async {
    when(mockUseCase.call('1')).thenAnswer((_) async => Success(tProductDetails));

    expectLater(
      viewModel.stream,
      emitsInOrder([
        isA<ProductDetailsState>().having((s) => s.resource.status, 'status', ApiStatus.loading),
        isA<ProductDetailsState>().having((s) => s.resource.status, 'status', ApiStatus.success)
            .having((s) => s.resource.data, 'data', tProductDetails),
      ]),
    );

    viewModel.doEvent(LoadProductDetails('1'));
  });

  test('loadDetails should emit loading then error on failure', () async {
    when(mockUseCase.call('1')).thenAnswer((_) async => Failure('Error message'));

    expectLater(
      viewModel.stream,
      emitsInOrder([
        isA<ProductDetailsState>().having((s) => s.resource.status, 'status', ApiStatus.loading),
        isA<ProductDetailsState>().having((s) => s.resource.status, 'status', ApiStatus.error)
            .having((s) => s.resource.errorMessage, 'error', 'Error message'),
      ]),
    );

    viewModel.doEvent(LoadProductDetails('1'));
  });

  test('updateImageIndex should update the current image index', () {
    expect(viewModel.state.currentImageIndex, 0);
    
    viewModel.doEvent(UpdateImageIndex(2));
    
    expect(viewModel.state.currentImageIndex, 2);
  });
}
