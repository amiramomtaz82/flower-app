import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';

import 'my_orders_events.dart';
import 'my_orders_state.dart';

@injectable
class MyOrdersCubit extends Cubit<MyOrdersState> {
  MyOrdersCubit() : super(MyOrdersState());

  Future<void> doEvents(MyOrdersEvent event) async {
    switch (event) {
      case MyOrdersStarted():
        await _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    emit(state.copyWith(
      activeOrders: Resource.loading(),
      completedOrders: Resource.loading(),
    ));

    await Future.delayed(const Duration(milliseconds: 800));

    final active = [
      const OrderEntity(
        id: '1',
        productName: 'Red roses',
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
        currency: 'EGP',
        price: 600,
        status: OrderStatus.active,
        orderNumber: '123456',
      ),
      const OrderEntity(
        id: '2',
        productName: 'Red roses',
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
        currency: 'EGP',
        price: 600,
        status: OrderStatus.active,
        orderNumber: '123456',
      ),
    ];

    final completed = [
      const OrderEntity(
        id: '3',
        productName: 'Red roses',
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
        currency: 'EGP',
        price: 600,
        status: OrderStatus.completed,
        deliveredOn: '3 Sep 2024',
      ),
      const OrderEntity(
        id: '4',
        productName: 'Red roses',
        imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=800&q=80',
        currency: 'EGP',
        price: 600,
        status: OrderStatus.completed,
        deliveredOn: '3 Sep 2024',
      ),
    ];

    emit(state.copyWith(
      activeOrders: Resource.success(active),
      completedOrders: Resource.success(completed),
    ));
  }
}
