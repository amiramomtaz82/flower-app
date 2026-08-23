import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/product_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetProductsByCategoryUseCase {
  final CommerceRepo _commerceRepo;
  GetProductsByCategoryUseCase(this._commerceRepo);

  Future<BaseResponse<List<ProductEntity>>> call({
    required String categoryId,
  }) {
    return _commerceRepo.getProductsByCategory(categoryId: categoryId);
  }
}
