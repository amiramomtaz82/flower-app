import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/domain/repositories/order_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrdersUseCase {
  GetOrdersUseCase(this.repository);

  final OrderRepository repository;

  Future<List<OrderEntity>> call() {
    return repository.getOrders();
  }
}
