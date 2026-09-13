import 'package:equatable/equatable.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/config/resource/rsource.dart';

class MyOrdersState extends Equatable {
  MyOrdersState({
    Resource<List<OrderEntity>>? activeOrders,
    Resource<List<OrderEntity>>? completedOrders,
  })  : activeOrders = activeOrders ?? Resource.initial(),
        completedOrders = completedOrders ?? Resource.initial();

  final Resource<List<OrderEntity>> activeOrders;
  final Resource<List<OrderEntity>> completedOrders;

  MyOrdersState copyWith({
    Resource<List<OrderEntity>>? activeOrders,
    Resource<List<OrderEntity>>? completedOrders,
  }) {
    return MyOrdersState(
      activeOrders: activeOrders ?? this.activeOrders,
      completedOrders: completedOrders ?? this.completedOrders,
    );
  }

  @override
  List<Object?> get props => [activeOrders, completedOrders];
}
