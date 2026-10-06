import 'package:injectable/injectable.dart';
import 'package:flower_app/core/network/base_response.dart';
import '../repositories/order_repository.dart';

@injectable
class ConfirmOrderDeliveryUseCase {
  ConfirmOrderDeliveryUseCase(this.repository);

  final OrderRepository repository;

  Future<BaseResponse<bool>> call(String orderId) {
    return repository.confirmOrderDelivery(orderId);
  }
}