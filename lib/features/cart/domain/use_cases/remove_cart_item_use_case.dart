import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/cart_entity.dart';
import '../repo/cart_repo.dart';

@injectable
class RemoveCartItemUseCase {
  RemoveCartItemUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<BaseResponse<CartEntity>> call({required String cartItemId}) async {
    return await _cartRepo.removeCartItem(cartItemId: cartItemId);
  }
}
