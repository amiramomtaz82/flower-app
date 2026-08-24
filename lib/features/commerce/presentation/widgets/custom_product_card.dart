import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product_entity.dart';

class CustomProductCard extends StatelessWidget {
  final ProductEntity product;

  const CustomProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.productDetails,
          extra: product,
        );
      },
      child: Container(
        height: 280,
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
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
              ),

              const SizedBox(height: 5),

              // Product name
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  product.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),

              const SizedBox(height: 5),

              // Prices
              Row(
                children: [
                  Text(
                    product.currency ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 2),

                  Flexible(
                    child: Text(
                      '${product.price ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Flexible(
                    child: Text(
                      '${product.originalPrice ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                  ),

                  const SizedBox(width: 3),

                  Text(
                    product.discountPercentage == null
                        ? ''
                        : '${product.discountPercentage}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryFixedDim,
                        ),
                  ),
                ],
              ),

              const Spacer(),

              // Add to cart
          Padding(
  padding: const EdgeInsets.only(
    bottom: 8,
  ),
  child: SizedBox(
    width: double.infinity,
    height: 30,
    child: ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(
        Icons.shopping_cart_outlined,
        size: 16,
      ),
      label: const Text(
        'Add to cart',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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