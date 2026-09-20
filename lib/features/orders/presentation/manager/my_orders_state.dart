import 'package:equatable/equatable.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';

class MyOrdersState extends Equatable {
  MyOrdersState({
    PaginationState<OrderEntity>? paginationState,
  }) : paginationState = paginationState ?? PaginationState<OrderEntity>.initial();

  final PaginationState<OrderEntity> paginationState;

  MyOrdersState copyWith({
    PaginationState<OrderEntity>? paginationState,
  }) {
    return MyOrdersState(
      paginationState: paginationState ?? this.paginationState,
    );
  }

  @override
  List<Object?> get props => [paginationState];
}
