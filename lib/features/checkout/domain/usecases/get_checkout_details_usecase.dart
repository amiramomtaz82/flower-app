
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../entities/checkout_details_entity.dart';
import '../repo/checkout_repo.dart';

@injectable
class GetCheckoutDetailsUseCase {
  final CheckoutRepository _repository;

  GetCheckoutDetailsUseCase(this._repository);

  Future<BaseResponse<CheckoutDetailsEntity>> call(String cartId) {
    return _repository.getCheckoutDetails(cartId);
  }
}