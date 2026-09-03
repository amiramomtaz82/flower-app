import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_state.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_event.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsView extends StatefulWidget {
  final ProductEntity? product;

  const ProductDetailsView({super.key, this.product});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  @override
  void initState() {
    super.initState();
    if (widget.product?.id != null) {
      context.read<ProductDetailsViewModel>().doEvent(LoadProductDetails(widget.product!.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onSurface),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: BlocBuilder<ProductDetailsViewModel, ProductDetailsState>(
        builder: (context, state) {
          final resource = state.resource;
          if (resource.isLoading || resource.status == ApiStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resource.status == ApiStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(resource.errorMessage ?? 'error'.tr()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.product?.id != null) {
                        context
                            .read<ProductDetailsViewModel>()
                            .doEvent(LoadProductDetails(widget.product!.id!));
                      }
                    },
                    child: Text('retry'.tr()),
                  )
                ],
              ),
            );
          }

          final details = resource.data;
          if (details == null) {
            return const SizedBox.shrink();
          }

          final images = details.images ?? [details.imageUrl ?? ''];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          context.read<ProductDetailsViewModel>().doEvent(UpdateImageIndex(index));
                        },
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.image, size: 50),
                            ),
                          );
                        },
                      ),
                    ),
                    if (images.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.currentImageIndex == index
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (details.price != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${details.currency ?? ""} ${details.price}',
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'All prices include tax',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                details.status ?? 'Unknown',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        details.name ?? "",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (details.description != null &&
                          details.description!.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          details.description!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (details.includes != null &&
                          details.includes!.isNotEmpty) ...[
                        Text(
                          'Bouquet include',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...details.includes!.map(
                          (include) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Text("• "),
                                Text(
                                  include.name ?? "",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text("Add to cart"),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
