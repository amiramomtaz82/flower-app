import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/address_entity.dart';

/// Static placeholder data. Will be swapped for the real
/// `AddressCubit`/`GetSavedAddressesEvent` state once this is wired up.
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

class SavedAddressesListView extends StatelessWidget {
  const SavedAddressesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved address')),
      body: _dummyAddresses.isEmpty
          ? Center(
              child: Text(
                'No saved addresses yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyAddresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = _dummyAddresses[index];
                return _AddressCard(address: address, colors: colors);
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
                        address.label ?? '',
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
