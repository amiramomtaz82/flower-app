import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../Address/presentaion/manager/address_cubit.dart';
import '../../../../Address/presentaion/manager/address_events.dart';
import '../../../../Address/presentaion/manager/address_state.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/home_section_entity.dart';
import '../../../domain/entities/home_section_type.dart';
import '../../../domain/entities/occasion_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../manager/home_cubit.dart';
import '../manager/home_state.dart';
import '../widgets/best_seller_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/deliver_to_row.dart';
import '../widgets/home_horizontal_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/occasion_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ---------- logo, search bar ------------------
                  Row(
                    children: [
                      Image.asset(AppAssets.logo, height: 26),
                      const SizedBox(width: 8),
                      const Expanded(child: HomeSearchBar()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---------- deliver to ------------------
                  BlocBuilder<AddressCubit, AddressState>(
                    builder: (context, state) {
                      final address = state.selectedAddress;

                      return InkWell(
                        onTap: () {
                          final addresses = context
                              .read<AddressCubit>()
                              .state
                              .addresses;

                          if (addresses.isEmpty) {
                            context.push(AppRoutes.addAddress);
                            return;
                          }
                          showModalBottomSheet(
                            context: context,
                            builder: (bottomSheetContext) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.addresses.length,
                                itemBuilder: (context, index) {
                                  final address = state.addresses[index];

                                  return ListTile(
                                    title: Text(
                                      address.label ?? 'Address',
                                    ),
                                    subtitle: Text(
                                      address.addressLine ?? '',
                                    ),
                                    trailing: address.id == state.selectedAddress?.id
                                        ? const Icon(Icons.check)
                                        : null,
                                    onTap: () {
                                      context.read<AddressCubit>().doEvents(
                                        SelectAddressEvent(address),
                                      );

                                      Navigator.pop(bottomSheetContext);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: DeliverToRow(
                          address: address?.addressLine ?? 'Add address',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ---------- sections, driven by /home/sections ------------------
                  // Selects only sectionsResource so adding/loading a single
                  // section's content doesn't rebuild this list — each
                  // section below re-selects its own resource independently.
                  BlocSelector<
                    HomeCubit,
                    HomeState,
                    Resource<List<HomeSectionEntity>>
                  >(
                    selector: (state) => state.sectionsResource,
                    builder: (context, sections) {
                      if (sections.isLoading ||
                          sections.status == ApiStatus.initial) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (sections.isError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text(
                              sections.errorMessage ?? 'Something went wrong',
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (final section
                              in sections.data ?? const <HomeSectionEntity>[])
                            _HomeSection(section: section),
                        ],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders one `/home/sections` entry, re-selecting only the resource it
/// needs so an unrelated section loading doesn't rebuild this one.
class _HomeSection extends StatelessWidget {
  const _HomeSection({required this.section});

  final HomeSectionEntity section;

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case HomeSectionType.categories:
        return BlocSelector<
          HomeCubit,
          HomeState,
          Resource<List<CategoryEntity>>
        >(
          selector: (state) => state.categoriesResource,
          builder: (context, resource) => HomeHorizontalSection(
            title: section.title ?? 'Categories',
            height: 96,
            isLoading:
                resource.isLoading || resource.status == ApiStatus.initial,
            errorMessage: resource.isError ? resource.errorMessage : null,
            itemCount: resource.data?.length ?? 0,
            onViewAll: () => context.go(AppRoutes.categories),
            itemBuilder: (context, index) {
              final category = resource.data![index];
              // opens the categories tab with this category already selected
              return CategoryChip(
                category: category,
                onTap: () =>
                    context.go(AppRoutes.categoriesForCategory(category.id)),
              );
            },
          ),
        );

      case HomeSectionType.occasions:
        return BlocSelector<
          HomeCubit,
          HomeState,
          Resource<List<OccasionEntity>>
        >(
          selector: (state) => state.occasionsResource,
          builder: (context, resource) => HomeHorizontalSection(
            title: section.title ?? 'Occasion',
            height: 170,
            isLoading:
                resource.isLoading || resource.status == ApiStatus.initial,
            errorMessage: resource.isError ? resource.errorMessage : null,
            itemCount: resource.data?.length ?? 0,
            onViewAll: () => context.push(AppRoutes.occasions),
            itemBuilder: (context, index) {
              final occasion = resource.data![index];
              // pushes the occasion page with this occasion already selected
              return OccasionCard(
                occasion: occasion,
                onTap: () =>
                    context.push(AppRoutes.occasionsForOccasion(occasion.id)),
              );
            },
          ),
        );

      case HomeSectionType.productsCarousel:
        return BlocSelector<
          HomeCubit,
          HomeState,
          Resource<List<ProductEntity>>
        >(
          selector: (state) =>
              state.carouselResources[section.id] ?? Resource.initial(),
          builder: (context, resource) => HomeHorizontalSection(
            title: section.title ?? 'Products',
            height: 230,
            isLoading:
                resource.isLoading || resource.status == ApiStatus.initial,
            errorMessage: resource.isError ? resource.errorMessage : null,
            itemCount: resource.data?.length ?? 0,
            itemBuilder: (context, index) =>
                BestSellerCard(product: resource.data![index]),
          ),
        );

      case HomeSectionType.bestSeller:
        return BlocSelector<
          HomeCubit,
          HomeState,
          Resource<List<ProductEntity>>
        >(
          selector: (state) => state.bestSellerResource,
          builder: (context, resource) => HomeHorizontalSection(
            title: section.title ?? 'Best seller',
            height: 230,
            isLoading:
                resource.isLoading || resource.status == ApiStatus.initial,
            errorMessage: resource.isError ? resource.errorMessage : null,
            itemCount: resource.data?.length ?? 0,
            itemBuilder: (context, index) =>
                BestSellerCard(product: resource.data![index]),
          ),
        );

      case HomeSectionType.unknown:
        return const SizedBox.shrink();
    }
  }

}
