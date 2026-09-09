import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/cart_entity.dart';
import '../repo/cart_repo.dart';

@injectable
class AddToCartUseCase {
  AddToCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<BaseResponse<CartEntity>> call({
    required String productId,
    int quantity = 1,
  }) async {
    return await _cartRepo.addToCart(
      productId: productId,
      quantity: quantity,
    );
  }
}
