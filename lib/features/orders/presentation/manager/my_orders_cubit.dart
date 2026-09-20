import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flower_app/features/orders/domain/use_cases/get_orders_use_case.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/core/pagination/pagination_controller.dart';
import 'my_orders_events.dart';
import 'my_orders_state.dart';

@injectable
class MyOrdersCubit extends Cubit<MyOrdersState> {
  MyOrdersCubit(this._getOrdersUseCase) : super(MyOrdersState()) {
    _paginationController = PaginationController<OrderEntity>(
      fetchPage: (page) => _getOrdersUseCase(pageNumber: page, pageSize: 10),
    );
  }

  final GetOrdersUseCase _getOrdersUseCase;
  late final PaginationController<OrderEntity> _paginationController;

  Future<void> doEvents(MyOrdersEvent event) async {
    switch (event) {
      case MyOrdersStarted():
        await _loadOrders();
      case MyOrdersLoadMore():
        await _loadMore();
      case MyOrdersRetry():
        await _retry();
    }
  }

  Future<void> _loadOrders() async {
    final newState = await _paginationController.loadInitialPage();
    emit(state.copyWith(paginationState: newState));
  }

  Future<void> _loadMore() async {
    final newState = await _paginationController.loadNextPage();
    emit(state.copyWith(paginationState: newState));
  }

  Future<void> _retry() async {
    final newState = await _paginationController.retry();
    emit(state.copyWith(paginationState: newState));
  }
}
