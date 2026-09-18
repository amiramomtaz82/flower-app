import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_cubit.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_events.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_state.dart';
import 'package:flower_app/features/orders/presentation/widgets/order_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyOrdersContent();
  }
}

class _MyOrdersContent extends StatelessWidget {
  const _MyOrdersContent();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppStrings.myOrders.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: false,
          bottom: TabBar(
            labelColor: colors?.primary ?? Theme.of(context).colorScheme.primary,
            unselectedLabelColor: colors?.grey ?? Colors.grey,
            indicatorColor: colors?.primary ?? Theme.of(context).colorScheme.primary,
            indicatorWeight: 2,
            tabs: [
              Tab(text: AppStrings.activeOrders.tr()),
              Tab(text: AppStrings.completedOrders.tr()),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrdersTab(status: OrderStatus.active),
            _OrdersTab(status: OrderStatus.completed),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOrdersCubit, MyOrdersState>(
      builder: (context, state) {
        final resource = state.paginationState.resource;

        if (resource.isLoading || resource.status == ApiStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (resource.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(resource.errorMessage ?? AppStrings.somethingWentWrong.tr()),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.read<MyOrdersCubit>().doEvents(MyOrdersStarted()),
                  child: Text(AppStrings.retry.tr()),
                ),
              ],
            ),
          );
        }

        final allOrders = resource.data ?? <OrderEntity>[];
        final orders = allOrders.where((o) => o.status == status).toList();

        if (orders.isEmpty) {
          return Center(
            child: Text(
              status == OrderStatus.active
                  ? AppStrings.noActiveOrders.tr()
                  : AppStrings.noCompletedOrders.tr(),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!state.paginationState.isLoadingMore &&
                state.paginationState.hasNextPage &&
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9) {
              context.read<MyOrdersCubit>().doEvents(MyOrdersLoadMore());
              return true;
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length + (state.paginationState.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == orders.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return OrderItemCard(order: orders[index]);
            },
          ),
        );
      },
    );
  }
}
