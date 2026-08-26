import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/home_section_entity.dart';
import '../../../domain/entities/home_section_type.dart';
import '../manager/home_cubit.dart';
import '../manager/home_state.dart';
import '../widgets/best_seller_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/deliver_to_row.dart';
import '../widgets/home_horizontal_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/occasion_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
                  const DeliverToRow(address: '2XVP+XC - Sheikh Zayed'),
                  const SizedBox(height: 24),

                  // ---------- sections, driven by /home/sections ------------------
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) => _HomeSections(state: state),
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

class _HomeSections extends StatelessWidget {
  const _HomeSections({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final sections = state.sectionsResource;

    if (sections.isLoading || sections.status == ApiStatus.initial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (sections.isError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(sections.errorMessage ?? 'Something went wrong'),
        ),
      );
    }

    return Column(
      children: [
        for (final section in sections.data ?? const <HomeSectionEntity>[])
          _buildSection(context, section),
      ],
    );
  }

  Widget _buildSection(BuildContext context, HomeSectionEntity section) {
    switch (section.type) {
      case HomeSectionType.categories:
        final resource = state.categoriesResource;
        return HomeHorizontalSection(
          title: section.title ?? 'Categories',
          height: 96,
          isLoading: resource.isLoading || resource.status == ApiStatus.initial,
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
        );

      case HomeSectionType.occasions:
        final resource = state.occasionsResource;
        return HomeHorizontalSection(
          title: section.title ?? 'Occasion',
          height: 170,
          isLoading: resource.isLoading || resource.status == ApiStatus.initial,
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
        );

      case HomeSectionType.productsCarousel:
        final resource =
            state.carouselResources[section.id] ?? Resource.initial();
        return HomeHorizontalSection(
          title: section.title ?? 'Products',
          height: 230,
          isLoading: resource.isLoading || resource.status == ApiStatus.initial,
          errorMessage: resource.isError ? resource.errorMessage : null,
          itemCount: resource.data?.length ?? 0,
          itemBuilder: (context, index) =>
              BestSellerCard(product: resource.data![index]),
        );

      case HomeSectionType.bestSeller:
        final resource = state.bestSellerResource;
        return HomeHorizontalSection(
          title: section.title ?? 'Best seller',
          height: 230,
          isLoading: resource.isLoading || resource.status == ApiStatus.initial,
          errorMessage: resource.isError ? resource.errorMessage : null,
          itemCount: resource.data?.length ?? 0,
          itemBuilder: (context, index) =>
              BestSellerCard(product: resource.data![index]),
        );

      case HomeSectionType.unknown:
        return const SizedBox.shrink();
    }
  }
}
