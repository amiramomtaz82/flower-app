// lib/features/Address/presentaion/view/add_address_view.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_area_city_selcetor.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_default_toggel.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_map_section.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/adress_form_fileds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/add_address_entity.dart';
import '../manager/address_cubit.dart';
import '../manager/address_events.dart';
import '../manager/address_state.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _labelController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().doEvents(GetAreasWithCitiesEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submit(AddressState state) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (state.validSelectedArea == null || state.validSelectedCity == null) return;

    final entity = AddAddressEntity(
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      area: state.validSelectedArea!.id!,
      city: state.validSelectedCity!.id!,
      lat: state.selectedLocation?.latitude ?? 0.0,
      lng: state.selectedLocation?.longitude ?? 0.0,
      label: _labelController.text.trim(),
    );

    context.read<AddressCubit>().doEvents(AddAddressEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listenWhen: (prev, curr) => prev.addAddressResource != curr.addAddressResource,
      listener: (context, state) {
        if (state.addAddressResource.isSuccess) {
          context.pop();
        } else if (state.addAddressResource.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.addAddressResource.errorMessage ??
                    'Error',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddressCubit>();

        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.addAddress.tr())),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AddressMapSection(
                    selectedLocation: state.selectedLocation,
                    onLocationSelected: (loc) => cubit.doEvents(SelectLocationEvent(loc)),
                  ),
                  const SizedBox(height: 16),
                  AddressAreaCitySelectors(
                    areas: state.areas,
                    selectedArea: state.validSelectedArea,
                    availableCities: state.availableCities,
                    selectedCity: state.validSelectedCity,
                    onAreaChanged: (area) =>
                    area != null ? cubit.doEvents(SelectAreaEvent(area)) : null,
                    onCityChanged: (city) =>
                    city != null ? cubit.doEvents(SelectCityEvent(city)) : null,
                  ),
                  const SizedBox(height: 16),
                  AddressFormFields(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    addressLineController: _addressLineController,
                    labelController: _labelController,
                  ),
                  const SizedBox(height: 8),
                  AddressDefaultToggle(
                    isDefault: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.addAddressResource.isLoading ? null : () => _submit(state),
                      child: state.addAddressResource.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(AppStrings.saveAddress.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}