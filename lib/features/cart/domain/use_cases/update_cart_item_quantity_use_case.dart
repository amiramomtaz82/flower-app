import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/cart_entity.dart';
import '../repo/cart_repo.dart';

@injectable
class UpdateCartItemQuantityUseCase {
  UpdateCartItemQuantityUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<BaseResponse<CartEntity>> call({
    required String productId,
    required int quantity,
  }) async {
    return await _cartRepo.updateCartItemQuantity(
      productId: productId,
      quantity: quantity,
    );
  }
}
