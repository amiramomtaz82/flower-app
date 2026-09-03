// lib/features/commerce/presentation/home/widgets/home_address_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/go_routes/routes_name.dart';
import '../../../../Address/domain/entities/address_entity.dart';
import '../../../../Address/presentaion/manager/address_cubit.dart';
import '../../../../Address/presentaion/manager/address_events.dart';
import '../../../../Address/presentaion/manager/address_state.dart';

class HomeAddressHeader extends StatelessWidget {
  final VoidCallback? onNavigateToAddAddress;

  const HomeAddressHeader({
    super.key,
    this.onNavigateToAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        // 1. Loading address state
        if (state.getAddressesResource.isLoading) {
          return const SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // 2. Guest User -> Completely hidden
        if (state.isGuest == true) {
          return const SizedBox.shrink();
        }

        // 3. Authenticated, but no addresses saved -> Prompt "Add Address"
        if (state.addresses.isEmpty) {
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onNavigateToAddAddress ?? () => context.push(AppRoutes.addAddress),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No address found. Tap to add address',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add Address',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 4. Authenticated with 1 Address -> Single row display
        if (state.addresses.length == 1) {
          final singleAddress = state.addresses.first;
          final title = (singleAddress.label?.isNotEmpty ?? false)
              ? singleAddress.label!
              : (singleAddress.addressLine ?? 'Default Address');

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 5. Authenticated with Multiple Addresses -> Safe Dropdown menu
        final selectedId = state.selectedAddress?.id;
        final selectedValue = (selectedId != null &&
            state.addresses.any((a) => a.id != null && a.id == selectedId))
            ? state.addresses.firstWhere((a) => a.id == selectedId)
            : state.addresses.first;

        return DropdownButtonHideUnderline(
          child: DropdownButton<AddressEntity>(
            isExpanded: true,
            value: selectedValue,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: state.addresses.map((addr) {
              final isDefault = addr.isDefault ?? false;
              final isCurrentSelected = addr.id != null && addr.id == selectedValue.id;
              final displayName = (addr.label?.isNotEmpty ?? false)
                  ? addr.label!
                  : (addr.addressLine ?? 'Address');

              return DropdownMenuItem<AddressEntity>(
                value: addr,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrentSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isDefault)
                      Container(
                        margin: const EdgeInsets.only(left: 8.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                context.read<AddressCubit>().doEvents(
                  SelectAddressEvent(selected),
                );
              }
            },
          ),
        );
      },
    );
  }
}