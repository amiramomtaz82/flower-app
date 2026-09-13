
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../entities/oder_placment_entity.dart';
import '../entities/place_order_request_entity.dart';
import '../repo/checkout_repo.dart';

@injectable
class PlaceOrderUseCase {
  final CheckoutRepository _repository;

  PlaceOrderUseCase(this._repository);

  Future<BaseResponse<OrderPlacementEntity>> call(PlaceOrderRequestEntity order) {
    return _repository.placeOrder(order);
  }
}