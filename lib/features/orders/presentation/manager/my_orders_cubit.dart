import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flower_app/config/resource/rsource.dart';

import 'package:flower_app/features/orders/domain/use_cases/get_orders_use_case.dart';
import 'my_orders_events.dart';
import 'my_orders_state.dart';

@injectable
class MyOrdersCubit extends Cubit<MyOrdersState> {
  MyOrdersCubit(this._getOrdersUseCase) : super(MyOrdersState());

  final GetOrdersUseCase _getOrdersUseCase;

  Future<void> doEvents(MyOrdersEvent event) async {
    switch (event) {
      case MyOrdersStarted():
        await _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    emit(state.copyWith(
      orders: Resource.loading(),
    ));

    try {
      final data = await _getOrdersUseCase();
      emit(state.copyWith(orders: Resource.success(data)));
    } catch (e) {
      emit(state.copyWith(orders: Resource.error(e.toString())));
    }
  }
}
