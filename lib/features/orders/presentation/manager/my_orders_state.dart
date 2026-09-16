import 'package:equatable/equatable.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/config/resource/rsource.dart';

class MyOrdersState extends Equatable {
  MyOrdersState({
    Resource<List<OrderEntity>>? orders,
  }) : orders = orders ?? Resource.initial();

  final Resource<List<OrderEntity>> orders;

  MyOrdersState copyWith({
    Resource<List<OrderEntity>>? orders,
  }) {
    return MyOrdersState(
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [orders];
}
