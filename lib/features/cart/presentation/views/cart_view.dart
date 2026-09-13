import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/cart_entity.dart';
import '../manager/cart_cubit.dart';
import '../manager/cart_events.dart';
import '../manager/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();

    
    final cubit = context.read<CartCubit>();
    if (cubit.state.cartResource.status == ApiStatus.initial) {
      cubit.doEvents(CartLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.home),
            ),
            title: Text(
              '${AppStrings.cart.tr()} '
              '${AppStrings.cartItemsCount.tr(args: ['${state.itemsCount}'])}',
              style: textTheme.titleLarge,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () =>
                context.read<CartCubit>().doEvents(CartLoaded()),
            child: _CartBody(state: state),
          ),
        );
      },
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = state.cart;

    if (state.cartResource.isLoading && cart == null) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (state.cartResource.isError && cart == null) {
      return _CartError(message: state.cartResource.errorMessage);
    }

    if (cart == null || cart.isEmpty) {
      return const _EmptyCart();
    }

    return Column(
      children: [
        Expanded(child: _CartItems(state: state, cart: cart)),
        CartSummaryCard(
          cart: cart,
          onCheckout: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.comingSoon.tr())),
          ),
        ),
      ],
    );
  }
}

class _CartItems extends StatelessWidget {
  const _CartItems({required this.state, required this.cart});

  final CartState state;
  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: cart.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        final productId = item.productId ?? '';
        final quantity = item.quantity ?? 0;

        return CartItemCard(
          item: item,
          isBusy:
              state.isMutating(productId) || state.isMutating(item.id ?? ''),
          onIncrement: () => cubit.doEvents(
            CartItemQuantityChanged(
              productId: productId,
              quantity: quantity + 1,
            ),
          ),
          onDecrement: () => cubit.doEvents(
            CartItemQuantityChanged(
              productId: productId,
              quantity: quantity - 1,
            ),
          ),
          onRemove: () => cubit.doEvents(CartItemRemoved(item.id ?? '')),
        );
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 96),
      children: [
        Icon(Icons.shopping_cart_outlined, size: 64, color: colors.grey),
        const SizedBox(height: 16),
        Text(
          AppStrings.yourCartIsEmpty.tr(),
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.cartEmptyHint.tr(),
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: colors.darkGrey),
        ),
      ],
    );
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 96),
      children: [
        Text(
          (message ?? AppStrings.somethingWentWrong).tr(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.read<CartCubit>().doEvents(CartLoaded()),
          child: Text('retry'.tr()),
        ),
      ],
    );
  }
}
