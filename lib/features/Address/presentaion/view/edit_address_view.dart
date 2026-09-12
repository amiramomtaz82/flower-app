import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/Address/domain/entities/address_entity.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_cubit.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_events.dart';
import 'package:flower_app/features/Address/presentaion/manager/address_state.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_area_city_selcetor.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_map_section.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/adress_form_fileds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class EditAddressView extends StatefulWidget {
  final AddressEntity address;

  const EditAddressView({
    super.key,
    required this.address,
  });

  @override
  State<EditAddressView> createState() => _EditAddressViewState();
}

class _EditAddressViewState extends State<EditAddressView> {
  static const Color _primaryPink = Color(0xFFD21E6A);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _labelController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.recipientName ?? '');
    _phoneController = TextEditingController(text: widget.address.recipientPhone ?? '');
    _addressLineController = TextEditingController(text: widget.address.addressLine ?? '');
    _labelController = TextEditingController(text: widget.address.label ?? '');
    _isDefault = widget.address.isDefault ?? false;

    final cubit = context.read<AddressCubit>();
    cubit.doEvents(GetAreasWithCitiesEvent());

    if (widget.address.lat != null && widget.address.lng != null) {
      cubit.doEvents(SelectLocationEvent(LatLng(widget.address.lat!, widget.address.lng!)));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAddress.tr()),
        content: Text(
          widget.address.isDefault == true
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
              if (widget.address.id != null) {
                context.read<AddressCubit>().doEvents(
                  DeleteAddressEvent(widget.address.id!),
                );
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

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final state = context.read<AddressCubit>().state;
    final areaId = state.validSelectedArea?.id ?? widget.address.areaId;
    final cityId = state.validSelectedCity?.id ?? widget.address.cityId;

    if (areaId == null || cityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectArea.tr())),
      );
      return;
    }

    final updatedEntity = widget.address.copyWith(
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      areaId: state.selectedArea!.id,
      cityId: cityId,
      lat: state.selectedLocation?.latitude ?? widget.address.lat ?? 0.0,
      lng: state.selectedLocation?.longitude ?? widget.address.lng ?? 0.0,
      label: _labelController.text.trim().isNotEmpty
          ? _labelController.text.trim()
          : (widget.address.label ?? AppStrings.defaultLabelHome.tr()),
      isDefault: _isDefault,
    );

    if (widget.address.id != null) {
      context.read<AddressCubit>().doEvents(
        UpdateAddressEvent(id: widget.address.id!, entity: updatedEntity),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddressCubit, AddressState>(
          listenWhen: (prev, curr) =>
          prev.updateAddressResource != curr.updateAddressResource,
          listener: (context, state) {
            if (state.updateAddressResource.isSuccess) {
              if (_isDefault && widget.address.id != null) {
                context.read<AddressCubit>().doEvents(
                  SetDefaultAddressEvent(widget.address.id!),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.addressUpdatedSuccessfully.tr()),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else if (state.updateAddressResource.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.updateAddressResource.errorMessage ??
                        AppStrings.updateFailed.tr(),
                  ),
                ),
              );
            }
          },
        ),
        BlocListener<AddressCubit, AddressState>(
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
              context.pop();
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
        ),
        BlocListener<AddressCubit, AddressState>(
          listenWhen: (prev, curr) =>
          prev.locationDetailsResource != curr.locationDetailsResource,
          listener: (context, state) {
            if (state.locationDetailsResource.isSuccess &&
                state.selectedLocationDetails?.addressLine != null) {
              _addressLineController.text =
              state.selectedLocationDetails!.addressLine!;
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(AppStrings.address.tr()),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _showDeleteConfirmation,
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  BlocBuilder<AddressCubit, AddressState>(
                    buildWhen: (prev, curr) =>
                    prev.selectedLocation != curr.selectedLocation,
                    builder: (context, state) {
                      return AddressMapSection(
                        selectedLocation: state.selectedLocation ??
                            (widget.address.lat != null && widget.address.lng != null
                                ? LatLng(widget.address.lat!, widget.address.lng!)
                                : null),
                        isLoadingLocation: false,
                        onLocationSelected: (loc) => context
                            .read<AddressCubit>()
                            .doEvents(SelectLocationEvent(loc)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AddressFormFields(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    addressLineController: _addressLineController,
                    labelController: _labelController,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AddressCubit, AddressState>(
                    buildWhen: (prev, curr) =>
                    prev.areas != curr.areas ||
                        prev.validSelectedArea != curr.validSelectedArea ||
                        prev.availableCities != curr.availableCities ||
                        prev.validSelectedCity != curr.validSelectedCity,
                    builder: (context, state) {
                      final cubit = context.read<AddressCubit>();
                      return AddressAreaCitySelectors(
                        areas: state.areas,
                        selectedArea: state.validSelectedArea,
                        availableCities: state.availableCities,
                        selectedCity: state.validSelectedCity,
                        onAreaChanged: (area) => area != null
                            ? cubit.doEvents(SelectAreaEvent(area))
                            : null,
                        onCityChanged: (city) => city != null
                            ? cubit.doEvents(SelectCityEvent(city))
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AddressCubit, AddressState>(
                    buildWhen: (prev, curr) =>
                    prev.updateAddressResource.isLoading !=
                        curr.updateAddressResource.isLoading,
                    builder: (context, state) {
                      final isLoading = state.updateAddressResource.isLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: isLoading ? null : _onSubmit,
                          child: isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            AppStrings.saveAddress.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}