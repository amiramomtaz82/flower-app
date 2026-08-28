
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product_entity.dart';

class CustomProductCard extends StatelessWidget {
  final ProductEntity product;

  const CustomProductCard({super.key, required this.product});

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
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 16),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "Add to cart",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
