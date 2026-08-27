
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
              Image.network(
                product.imageUrl ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    AppAssets.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  product.name ?? "",
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height:5,),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "${product.currency ?? ''} ${product.price ?? ''}",
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (product.originalPrice != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "${product.originalPrice}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (product.discountPercentage != null) ...[
                    const SizedBox(width: 3),
                    Text(
                      "${product.discountPercentage}%",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondaryFixedDim),
                    ),
                  ],
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(height:30 ,
                  child: ElevatedButton(onPressed: (){}, child:Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined),
                      SizedBox(width: 4,),
                      Text("Add to cart")
                    ],
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
