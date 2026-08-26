import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/occasion_entity.dart';
import '../../widgets/centered_message.dart';
import '../../widgets/products_resource_grid.dart';
import '../../widgets/selection_tabs.dart';
import '../manager/occasions_cubit.dart';
import '../manager/occasions_events.dart';
import '../manager/occasions_state.dart';

class OccasionsView extends StatelessWidget {
  const OccasionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          // deep links land here with nothing to pop back to
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text('Occasion', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: BlocBuilder<OccasionsCubit, OccasionsState>(
          builder: (context, state) {
            final occasions = state.occasionsResource;

            if (occasions.isLoading || occasions.status == ApiStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (occasions.isError) {
              return CenteredMessage(text: occasions.errorMessage);
            }

            final data = occasions.data ?? const <OccasionEntity>[];
            if (data.isEmpty) {
              return const CenteredMessage(text: 'No occasions yet');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'Bloom with our exquisite best sellers',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: SelectionTabs(
                    tabs: [
                      for (final occasion in data)
                        SelectionTab(id: occasion.id, label: occasion.name),
                    ],
                    selectedId: state.selectedOccasionId,
                    onSelected: (occasionId) => context
                        .read<OccasionsCubit>()
                        .doEvents(OccasionSelected(occasionId)),
                  ),
                ),
                Expanded(
                  child: ProductsResourceGrid(
                    resource: state.productsResource,
                    emptyMessage: 'No products for this occasion yet',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
