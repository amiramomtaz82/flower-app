import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../api/data_source_impl/local/dummy_categories.dart';
import '../../../api/data_source_impl/local/dummy_data.dart';
import '../../../api/data_source_impl/local/dummy_occasions.dart';
import '../widgets/best_seller_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/deliver_to_row.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/occasion_card.dart';
import '../widgets/section_header.dart';

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

                  // ---------- categories ------------------
                  SectionHeader(
                    title: 'Categories',
                    onViewAll: () {
                      context.go(AppRoutes.categories, extra: '1');
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dummyCategories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final category = dummyCategories[index];
                        return CategoryChip(
                          category: category,
                          onTap: () {
                            context.go(
                              '${AppRoutes.categories}?categoryId=${category.id}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- best seller ------------------
                  SectionHeader(title: 'Best seller', onViewAll: () {}),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dummyList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          BestSellerCard(product: dummyList[index]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------- occasions ------------------
                  SectionHeader(title: 'Occasion', onViewAll: () {}),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dummyOccasions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          OccasionCard(
                            occasion: dummyOccasions[index],
                             onTap: () {
    context.push(
  '${AppRoutes.occasionProducts}?occasionId=${dummyOccasions[index].id}',
);
  },
                            ),
                    ),
                  ),
                  // const SizedBox(height: 10),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
