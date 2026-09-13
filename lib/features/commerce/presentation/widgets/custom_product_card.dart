
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/guest_browsing/guest_browsing_provider.dart';
import 'package:flower_app/core/ui_action/ui_action.dart';
import 'package:flower_app/core/ui_action/ui_action_dispatcher.dart';
import 'package:flower_app/features/cart/presentation/manager/cart_cubit.dart';
import 'package:flower_app/features/cart/presentation/manager/cart_events.dart';
import 'package:flower_app/features/cart/presentation/manager/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product_entity.dart';

class CustomProductCard extends StatelessWidget {
  final ProductEntity product;

  const CustomProductCard({super.key, required this.product});

  // holds the API's inStock value
  bool get _isInStock => product.isBestSeller == true;

  String _buttonLabel(bool isInCart) {
    if (!_isInStock) return AppStrings.outOfStock;
    return isInCart ? AppStrings.addedToCart : AppStrings.addToCart;
  }

  IconData _buttonIcon(bool isInCart) {
    if (!_isInStock) return Icons.remove_shopping_cart_outlined;
    return isInCart ? Icons.check : Icons.shopping_cart_outlined;
  }

  void _onCartButtonPressed(BuildContext context) {
    if (!_isInStock) {
      getIt<UiActionDispatcher>().dispatch(
        const ShowSnackBarAction.error(AppStrings.productOutOfStockCurrently),
      );
      return;
    }

    final productId = product.id;
    if (productId == null) return;

    final cartCubit = context.read<CartCubit>();
    final cartItemId = cartCubit.state.cartItemIdFor(productId);

    getIt<GuestBrowsingProvider>().requireAuth(
      action: () => cartCubit.doEvents(
        cartItemId != null
            ? CartItemRemoved(cartItemId)
            : CartItemAdded(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final originalPrice = product.originalPrice;
    final discount = product.discountPercentage;
    final hasOriginalPrice =
        originalPrice != null && originalPrice != product.price;
    final hasDiscount = discount != null && discount > 0;

    return InkWell(onTap: (){
      context.push(AppRoutes.productDetails,extra: product);
    },
      child: Container(
        height: 230,
        width: 163,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SizedBox(height: 8,),
              Expanded(
                child: Image.network(
                  product.imageUrl ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppAssets.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  height: 34,
                  child: Text(
                    product.name ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              SizedBox(height:5,),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [SizedBox(width: 8,),
                    Text(
                      product.currency ?? "",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),SizedBox(width: 2,),
                    Text("${product.price ?? ""}", style:
                    Theme.of(context).textTheme.bodyLarge),
                    if (hasOriginalPrice) ...[
                      SizedBox(width: 8),
                      Text("$originalPrice", style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough
                      )),
                    ],
                    if (hasDiscount) ...[
                      SizedBox(width: 3),
                      Text("$discount %",style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondaryFixedDim
                      ),),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 32,
                  width: double.infinity,
                  child: BlocBuilder<CartCubit, CartState>(
                    buildWhen: (previous, current) =>
                        previous.containsProduct(product.id) !=
                        current.containsProduct(product.id),
                    builder: (context, cartState) {
                      final isInCart = cartState.containsProduct(product.id);

                      return ElevatedButton(
                        onPressed: () => _onCartButtonPressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isInStock
                              ? null
                              : Theme.of(
                                  context,
                                ).extension<LightColors>()!.darkGrey,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_buttonIcon(isInCart), size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _buttonLabel(isInCart).tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
