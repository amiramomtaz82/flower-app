import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../Address/presentaion/manager/address_cubit.dart';
import '../../../../Address/presentaion/manager/address_events.dart';
import '../../../../Address/presentaion/manager/address_state.dart';
import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';
import 'checkout_address_card.dart';

class CheckoutAddressSection extends StatelessWidget {
  final String cartId;
  final AppColors colors;

  const CheckoutAddressSection({
    super.key,
    required this.cartId,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.deliveryAddress.tr(),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),
          BlocBuilder<AddressCubit, AddressState>(
            builder: (context, addressState) {
              final addresses = addressState.addresses;

              return BlocBuilder<CheckoutCubit, CheckoutState>(
                buildWhen: (prev, curr) =>
                prev.selectedAddressId != curr.selectedAddressId,
                builder: (context, checkoutState) {
                  final cubit = context.read<CheckoutCubit>();

                  return Column(
                    children: [
                      if (addresses.isEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            AppStrings.noSavedAddresses.tr(),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final addressItem = addresses[index];
                            final isSelected =
                                checkoutState.selectedAddressId == addressItem.id ||
                                    (checkoutState.selectedAddressId == null &&
                                        addressItem.id ==
                                            addressState.selectedAddress?.id);

                            return CheckoutAddressCard(
                              address: addressItem,
                              isSelected: isSelected,
                              onTap: () {
                                context
                                    .read<AddressCubit>()
                                    .doEvents(SelectAddressEvent(addressItem));
                                cubit.doEvents(
                                  EstimateDeliveryEvent(
                                    addressId: addressItem.id ?? '',
                                    cartId: cartId,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.grey, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => context.push(AppRoutes.addAddress),
                          icon: Icon(Icons.add, size: 20, color: colors.primary),
                          label: Text(
                            AppStrings.addNew.tr(),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}