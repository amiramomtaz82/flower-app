import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/domain/repositories/order_repository.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrdersUseCase {
  GetOrdersUseCase(this.repository);

  final OrderRepository repository;

  Future<BaseResponse<PaginatedResponse<OrderEntity>>> call({
    required int pageNumber,
    required int pageSize,
  }) {
    return repository.getOrders(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }
}
