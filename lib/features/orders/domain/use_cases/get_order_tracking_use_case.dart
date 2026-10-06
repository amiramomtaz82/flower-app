import 'package:injectable/injectable.dart';
import 'package:flower_app/core/network/base_response.dart';
import '../entities/order_tracking_entity.dart';
import '../repositories/order_repository.dart';

@injectable
class GetOrderLiveTrackingUseCase {
  GetOrderLiveTrackingUseCase(this.repository);

  final OrderRepository repository;

  Future<BaseResponse<OrderTrackingEntity>> call(String orderId) {
    return repository.getLiveTracking(orderId);
  }
}