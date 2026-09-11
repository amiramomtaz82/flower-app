import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
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

  static const Color _primaryPink = Color(0xFFD21E6A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AddressCubit, AddressState>(
      buildWhen: (prev, curr) =>
      prev.isGuest != curr.isGuest ||
          prev.getAddressesResource != curr.getAddressesResource ||
          prev.addresses != curr.addresses ||
          prev.selectedAddress != curr.selectedAddress,
      builder: (context, state) {
        // 1. Session check in progress or addresses loading
        if (state.isGuest == null || state.getAddressesResource.isLoading) {
          return const SizedBox(
            height: 36,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // 2. Confirmed Guest
        if (state.isGuest == true) {
          return InkWell(
            onTap: () => context.push(AppRoutes.login),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.signInToAddAddress.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Authenticated, but no addresses saved
        if (state.addresses.isEmpty) {
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onNavigateToAddAddress ?? () => context.push(AppRoutes.addAddress),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      AppStrings.noAddressFound.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.addAddress.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 4. Authenticated with 1 or More Addresses -> Figma Style Dropdown
        final selectedId = state.selectedAddress?.id;

        final selectedValue = (selectedId != null &&
            state.addresses.any((a) => a.id != null && a.id == selectedId))
            ? state.addresses.firstWhere((a) => a.id == selectedId)
            : state.addresses.firstWhere(
              (a) => a.isDefault == true,
          orElse: () => state.addresses.first,
        );

        return DropdownButtonHideUnderline(
          child: DropdownButton<AddressEntity>(
            isExpanded: true,
            value: selectedValue,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _primaryPink,
              size: 22,
            ),
            selectedItemBuilder: (context) {
              // Header display matching Figma: [Pin] Deliver to <Address> [Arrow]
              return state.addresses.map((addr) {
                final displayLocation = (addr.addressLine?.trim().isNotEmpty == true)
                    ? addr.addressLine!.trim()
                    : (addr.label?.trim().isNotEmpty == true
                    ? addr.label!.trim()
                    : (addr.areaId?.trim() ?? AppStrings.address.tr()));

                return Column(
                  children: [ InkWell
                    (onTap: (){context.push(AppRoutes.checkout);},
                    child: Text("go check out view "),


                  ),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Deliver to ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black54,
                                  ),
                                ),
                                TextSpan(
                                  text: displayLocation,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList();
            },
            items: state.addresses.map((addr) {
              final isCurrentSelected = addr.id != null && addr.id == selectedValue.id;
              final hasLabel = addr.label?.trim().isNotEmpty == true;
              final hasAddressLine = addr.addressLine?.trim().isNotEmpty == true;

              return DropdownMenuItem<AddressEntity>(
                value: addr,
                child: Row(
                  children: [

                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: isCurrentSelected ? _primaryPink : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isCurrentSelected ? _primaryPink : Colors.black87,
                            fontSize: 13,
                          ),
                          children: [
                            if (hasLabel) ...[
                              TextSpan(
                                text: addr.label!.trim(),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (hasAddressLine) const TextSpan(text: ' • '),
                            ],
                            if (hasAddressLine)
                              TextSpan(
                                text: addr.addressLine!.trim(),
                                style: TextStyle(
                                  fontWeight: (!hasLabel) ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            if (!hasLabel && !hasAddressLine)
                              TextSpan(
                                text: addr.areaId?.trim() ?? AppStrings.address.tr(),
                              ),
                          ],
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