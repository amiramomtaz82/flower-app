import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/product_entity.dart';
import '../repo/commerce_repo.dart';

@injectable
class GetProductByIdUseCase {
  final CommerceRepo _commerceRepo;
  GetProductByIdUseCase(this._commerceRepo);

  Future<BaseResponse<ProductEntity>> call({required String productId}) {
    return _commerceRepo.getProductById(productId: productId);
  }
}
