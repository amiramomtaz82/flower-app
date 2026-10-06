import 'package:injectable/injectable.dart';
import '../entities/order_tracking_update_entity.dart';
import '../repositories/order_repository.dart';

@injectable
class GetOrderTrackingUpdatesUseCase {
  final OrderRepository repository;

  GetOrderTrackingUpdatesUseCase(this.repository);

  Stream<OrderTrackingUpdateEntity> call(String orderId) {
    return repository.getTrackingUpdatesStream(orderId);
  }
}