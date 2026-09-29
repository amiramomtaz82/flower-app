import 'package:flower_app/features/orders/domain/oredr_details_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:flower_app/core/network/base_response.dart';

import '../repositories/order_repository.dart';

@injectable
class GetOrderByIdUseCase {
  GetOrderByIdUseCase(this.repository);

  final OrderRepository repository;

  Future<BaseResponse<OrderDetailsEntity>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}