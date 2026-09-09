import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../entities/cart_entity.dart';
import '../repo/cart_repo.dart';

@injectable
class GetCartUseCase {
  GetCartUseCase(this._cartRepo);

  final CartRepo _cartRepo;

  Future<BaseResponse<CartEntity>> call() async {
    return await _cartRepo.getCart();
  }
}
