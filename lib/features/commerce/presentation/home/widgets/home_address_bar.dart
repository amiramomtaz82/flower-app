import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/go_routes/routes_name.dart';
import '../../../../Address/domain/entities/address_entity.dart';
import '../../../../Address/presentaion/manager/address_cubit.dart';
import '../../../../Address/presentaion/manager/address_events.dart';
import '../../../../Address/presentaion/manager/address_state.dart';



class HomeAddressBar extends StatelessWidget {
  final VoidCallback? onAddAddressTap;

  const HomeAddressBar({
    super.key,
    this.onAddAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        // 1. Loading state
        if (state.getAddressesResource.isLoading) {
          return const SizedBox(
            height: 48,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // 2. Guest Check
        // If the user is a guest, selectedAddress is null and addresses list is empty
        // In this case, render nothing.
        if (state.selectedAddress == null && state.addresses.isEmpty) {
          return const SizedBox.shrink();
        }

        // 3. Logged in, but has 0 saved addresses
        // (selectedAddress == null, but guest check already resolved auth user)
        if (state.addresses.isEmpty) {
          return InkWell(
            onTap: () {
              if (onAddAddressTap != null) {
                onAddAddressTap!();
              } else {
                context.push(AppRoutes.addAddress);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No address saved. Tap to add address',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.add_circle_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        }

        // 4. Exactly 1 Address -> Single Non-clickable Line / Badge
        if (state.addresses.length == 1) {
          final address = state.addresses.first;
          final title = address.label?.isNotEmpty == true
              ? address.label!
              : (address.addressLine ?? 'Current Address');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
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

        // 5. Multiple Addresses -> Dropdown Picker
        final currentSelected = state.selectedAddress != null &&
            state.addresses.any((a) => a.id == state.selectedAddress!.id)
            ? state.addresses.firstWhere((a) => a.id == state.selectedAddress!.id)
            : state.addresses.first;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AddressEntity>(
              isExpanded: true,
              value: currentSelected,
              icon: const Icon(Icons.keyboard_arrow_down, size: 22),
              items: state.addresses.map((addr) {
                final isDefault = addr.isDefault ?? false;
                final displayName = addr.label?.isNotEmpty == true
                    ? addr.label!
                    : (addr.addressLine ?? 'Address');

                return DropdownMenuItem<AddressEntity>(
                  value: addr,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: addr.id == currentSelected.id
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
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
          ),
        );
      },
    );
  }
}