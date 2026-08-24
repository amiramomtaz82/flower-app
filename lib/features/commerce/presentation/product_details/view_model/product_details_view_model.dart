import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_product_details_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductDetailsViewModel extends Cubit<Resource<ProductDetailsEntity>> {
  final GetProductDetailsUseCase _getProductDetailsUseCase;

  ProductDetailsViewModel(this._getProductDetailsUseCase)
      : super(Resource.initial());

  Future<void> loadDetails(String id) async {
    emit(Resource.loading());

    try {
      final result = await _getProductDetailsUseCase(id);

      switch (result) {
        case SuccessResponse<ProductDetailsEntity>():
          emit(Resource.success(result.data));
        case ErrorResponse<ProductDetailsEntity>():
          emit(Resource.error(result.errMessage));
      }
    } catch (e) {
      emit(Resource.error(e.toString()));
    }
  }
}
