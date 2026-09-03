import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../manager/address_cubit.dart';
import '../manager/address_events.dart';
import '../manager/address_state.dart';

class AddressDetailsView extends StatefulWidget {
  const AddressDetailsView({super.key, required this.addressId});

  final String addressId;

  @override
  State<AddressDetailsView> createState() => _AddressDetailsViewState();
}

class _AddressDetailsViewState extends State<AddressDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().doEvents(
      GetAddressByIdEvent(widget.addressId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Address details')),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          final resource = state.getAddressByIdResource;
          final address = state.addressDetails;

          if (resource.isLoading && address?.id != widget.addressId) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resource.isError && address?.id != widget.addressId) {
            return Center(
              child: Text(
                resource.errorMessage ?? 'Could not load this address',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          if (address == null || address.id != widget.addressId) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (address.label?.trim().isNotEmpty ?? false)
                      ? address.label!
                      : 'Address',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: 'Recipient',
                  value: address.recipientName ?? '',
                  colors: colors,
                ),
                _DetailRow(
                  label: 'Phone',
                  value: address.recipientPhone ?? '',
                  colors: colors,
                ),
                _DetailRow(
                  label: 'Address',
                  value: address.addressLine ?? '',
                  colors: colors,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(
                      AppRoutes.editAddressFor(widget.addressId),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: colors.darkGrey),
          ),
          const SizedBox(height: 2),
          Text(value, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
