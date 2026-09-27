import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/domain/repositories/order_repository.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:injectable/injectable.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';

import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/oredr_details_entity.dart';

@Injectable(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this.remoteDataSource);

  final OrderRemoteDataSource remoteDataSource;

  @override
  Future<BaseResponse<PaginatedResponse<OrderEntity>>> getOrders({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await remoteDataSource.getOrders(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return SuccessResponse(
        PaginatedResponse<OrderEntity>(
          data: response.orders.map((o) => o.toEntity()).toList(),
          pagination: PaginationModel(
            page: response.pageNumber ?? pageNumber,
            pageSize: response.pageSize ?? pageSize,
            totalCount: response.totalCount ?? 0,
            totalPages: response.totalPages ?? 1,
            hasNextPage: response.hasNextPage ?? false,
            hasPreviousPage: response.hasPreviousPage ?? false,
          ),
        ),
      );
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }



  @override
  Future<BaseResponse<OrderTrackingEntity>> getLiveTracking(String orderId) async {
    try {
      final response = await remoteDataSource.getLiveTracking(orderId);
      if (response.data != null) {
        return SuccessResponse<OrderTrackingEntity>(response.data!.toEntity());
      }
      return ErrorResponse<OrderTrackingEntity>(
        errMessage: response.message ?? 'No tracking data available',
      );
    } catch (e) {
      return ErrorResponse<OrderTrackingEntity>(error: e);
    }
  }
  @override
  Future<BaseResponse<bool>> confirmOrderDelivery(String orderId) async {
    try {
      final result = await remoteDataSource.confirmOrderDelivery(orderId);
      return SuccessResponse<bool>(result);
    } catch (e) {
      return ErrorResponse<bool>(error: e);
    }
  }
  @override
  Future<BaseResponse<OrderDetailsEntity>> getOrderById(String orderId) async {
    try {
      final response = await remoteDataSource.getOrderById(orderId);
      return SuccessResponse<OrderDetailsEntity>(response.toEntity());
    } catch (e) {
      return ErrorResponse<OrderDetailsEntity>(error: e);
    }
  }

}
