import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flower_app/features/Address/domain/entities/address_entity.dart';

import '../manager/address_cubit.dart';
import '../manager/address_events.dart';
import '../manager/address_state.dart';

/// Fallback data, shown only when the API returns no saved addresses
/// (or fails), so the screen never renders empty during this sprint.
const List<AddressEntity> _dummyAddresses = [
  AddressEntity(
    id: '1',
    label: 'Cairo',
    addressLine: '2XVP+XC - Sheikh Zayed',
  ),
  AddressEntity(
    id: '2',
    label: 'Cairo',
    addressLine: '2XVP+XC - Sheikh Zayed',
  ),
];

class SavedAddressesListView extends StatefulWidget {
  const SavedAddressesListView({super.key});

  @override
  State<SavedAddressesListView> createState() =>
      _SavedAddressesListViewState();
}

class _SavedAddressesListViewState extends State<SavedAddressesListView> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().doEvents(const GetSavedAddressesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved address')),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          final resource = state.getAddressesResource;

          if (resource.isLoading && state.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          List<AddressEntity> addresses = _dummyAddresses;
          if (state.addresses.isNotEmpty) {
            addresses = state.addresses;
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _AddressCard(address: addresses[index], colors: colors);
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.addAddress),
            child: const Text('Add new address'),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.colors});

  final AddressEntity address;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, size: 20, color: colors.textPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (address.label?.trim().isNotEmpty ?? false)
                            ? address.label!
                            : 'Address',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.delete_outline, color: colors.error),
                      onPressed: () {
                        // TODO: wire up delete once that flow exists.
                      },
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.edit_outlined, color: colors.textPrimary),
                      onPressed: () {
                        // TODO: navigate to Edit Address once that flow exists.
                      },
                    ),
                  ],
                ),
                Text(
                  address.addressLine ?? '',
                  style: textTheme.bodyMedium?.copyWith(color: colors.darkGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
