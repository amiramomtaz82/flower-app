
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../entities/estimated_delivery_entity.dart';
import '../repo/checkout_repo.dart';

@injectable
class EstimateDeliveryUseCase {
  final CheckoutRepository _repository;

  EstimateDeliveryUseCase(this._repository);

  Future<BaseResponse<EstimateDeliveryEntity>> call({
    required String addressId,
    required String cartId,
  }) {
    return _repository.estimateDelivery(addressId, cartId);
  }
}