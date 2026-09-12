// lib/features/Address/presentaion/view/saved_addresses_view.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_cubit.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_events.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_state.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavedAddressesView extends StatefulWidget {
  const SavedAddressesView({super.key});

  @override
  State<SavedAddressesView> createState() => _SavedAddressesViewState();
}

class _SavedAddressesViewState extends State<SavedAddressesView> {
  static const Color _primaryPink = Color(0xFFD21E6A);

  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().doEvents(GetSavedAddressesEvent());
  }

  void _showDeleteConfirmation(BuildContext context, AddressEntity address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAddress.tr()),
        content: Text(
          address.isDefault == true
              ? AppStrings.deleteDefaultAddressWarning.tr()
              : AppStrings.deleteAddressConfirm.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (address.id != null) {
                context.read<AddressCubit>().doEvents(DeleteAddressEvent(address.id!));
              }
            },
            child: Text(
              AppStrings.delete.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AddressCubit, AddressState>(
      listenWhen: (prev, curr) =>
      prev.deleteAddressResource != curr.deleteAddressResource,
      listener: (context, state) {
        if (state.deleteAddressResource.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.addressDeletedSuccessfully.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.deleteAddressResource.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.deleteAddressResource.errorMessage ??
                    AppStrings.failedToDeleteAddress.tr(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(AppStrings.savedAddresses.tr()),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<AddressCubit, AddressState>(
                  buildWhen: (prev, curr) =>
                  prev.getAddressesResource != curr.getAddressesResource ||
                      prev.addresses != curr.addresses,
                  builder: (context, state) {
                    if (state.getAddressesResource.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.addresses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: theme.disabledColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.noAddressFound.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: state.addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final address = state.addresses[index];
                        return AddressCard(
                          address: address,
                          mode: AddressCardMode.management,
                          onDelete: () => _showDeleteConfirmation(context, address),
                          onEdit: () => context.push(AppRoutes.editAddress, extra: address),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => context.push(AppRoutes.addAddress),
                    child: Text(
                      AppStrings.addNewAddress.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}