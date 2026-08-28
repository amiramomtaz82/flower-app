import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_product_details_use_case.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_state.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductDetailsViewModel extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase _getProductDetailsUseCase;

  ProductDetailsViewModel(this._getProductDetailsUseCase)
      : super(ProductDetailsState(resource: Resource.initial()));

  void doEvent(ProductDetailsEvent event) {
    switch (event) {
      case LoadProductDetails():
        _loadDetails(event.id);
      case UpdateImageIndex():
        emit(state.copyWith(currentImageIndex: event.index));
    }
  }

  Future<void> _loadDetails(String id) async {
    emit(state.copyWith(resource: Resource.loading()));

    try {
      final result = await _getProductDetailsUseCase(id);

      switch (result) {
        case SuccessResponse<ProductDetailsEntity>():
          emit(state.copyWith(resource: Resource.success(result.data)));
        case ErrorResponse<ProductDetailsEntity>():
          emit(state.copyWith(resource: Resource.error(result.errMessage)));
      }
    } catch (e) {
      emit(state.copyWith(resource: Resource.error(e.toString())));
    }
  }
}
