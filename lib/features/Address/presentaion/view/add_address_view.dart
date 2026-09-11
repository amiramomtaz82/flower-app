
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/address_area_city_selcetor.dart';

import 'package:flower_app/features/Address/presentaion/view/widget/address_map_section.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/adress_form_fileds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../config/di/di.dart';
import '../../../../core/location/location_service.dart';
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
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().doEvents(GetAreasWithCitiesEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectAndApplyGpsLocation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  // ==================== Location & Permission Logic ====================

  Future<void> _detectAndApplyGpsLocation() async {
    final locationService = getIt<LocationService>();

    final serviceEnabled = await locationService.isServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      _showPermissionDialog(
        title: 'Enable Location',
        message: 'Location services are disabled. Please enable GPS on your device to pinpoint your location.',
        actionText: 'Open Settings',
        onConfirm: () => Geolocator.openLocationSettings(),
      );
      return;
    }

    var permission = await locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await locationService.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission was denied.')),
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showPermissionDialog(
        title: 'Permission Required',
        message: 'Location access is permanently blocked. Enable it in app settings.',
        actionText: 'App Settings',
        onConfirm: () => Geolocator.openAppSettings(),
      );
      return;
    }

    setState(() => _isLoadingGps = true);
    try {
      final position = await locationService.getCurrentPosition();
      if (position != null && mounted) {
        _applyLocation(position);
      }
    } finally {
      if (mounted) setState(() => _isLoadingGps = false);
    }
  }

  void _applyLocation(LatLng location) {
    context.read<AddressCubit>().doEvents(SelectLocationEvent(location));
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required String actionText,
    required Future<void> Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await onConfirm();
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  // ==================== Submit Logic ====================

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final state = context.read<AddressCubit>().state;
    if (state.validSelectedArea == null || state.validSelectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectArea.tr())),
      );
      return;
    }

    final entity = AddAddressEntity(
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      area: state.validSelectedArea!.id!,
      city: state.validSelectedCity!.id!,
      lat: state.selectedLocation?.latitude ?? 0.0,
      lng: state.selectedLocation?.longitude ?? 0.0,
      label: _labelController.text.trim().isNotEmpty
          ? _labelController.text.trim()
          : 'Home',
    );

    context.read<AddressCubit>().doEvents(AddAddressEvent(entity));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressCubit, AddressState>(
      listenWhen: (prev, curr) =>
      prev.addAddressResource != curr.addAddressResource ||
          prev.locationDetailsResource != curr.locationDetailsResource,
      listener: (context, state) {
        // Autofill address line once cubit completes reverse geocoding
        if (state.locationDetailsResource.isSuccess &&
            state.selectedLocationDetails?.addressLine != null) {
          _addressLineController.text =
          state.selectedLocationDetails!.addressLine!;
        }

        if (state.addAddressResource.isSuccess) {
          final createdAddress = state.addAddressResource.data;
          if (_isDefault && createdAddress?.id != null) {
            context.read<AddressCubit>().doEvents(
              SetDefaultAddressEvent(createdAddress!.id!),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.addressAddedSuccessfully.tr()),
              backgroundColor: Colors.green,
            ),
          );

          context.read<AddressCubit>().doEvents(GetSavedAddressesEvent());
          context.pop();
        } else if (state.addAddressResource.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.addAddressResource.errorMessage ?? 'Error',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.addAddress.tr()),
          centerTitle: false,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 1. Map Section — ONLY rebuilds on coordinate changes
                  BlocBuilder<AddressCubit, AddressState>(
                    buildWhen: (prev, curr) =>
                    prev.selectedLocation != curr.selectedLocation,
                    builder: (context, state) {
                      return AddressMapSection(
                        selectedLocation: state.selectedLocation,
                        isLoadingLocation: _isLoadingGps,
                        onLocationSelected: _applyLocation,
                        onLocateMePressed: _detectAndApplyGpsLocation,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Text Form Fields — Static; never rebuilds with BLoC emits
                  AddressFormFields(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    addressLineController: _addressLineController,
                    labelController: _labelController,
                  ),
                  const SizedBox(height: 16),

                  // 3. Dropdowns — ONLY rebuilds when Area/City selection or lists change
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
                  const SizedBox(height: 12),


                  const SizedBox(height: 24),

                  // 5. Submit Button — ONLY rebuilds when loading state toggles
                  BlocBuilder<AddressCubit, AddressState>(
                    buildWhen: (prev, curr) =>
                    prev.addAddressResource.isLoading !=
                        curr.addAddressResource.isLoading,
                    builder: (context, state) {
                      final isLoading = state.addAddressResource.isLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(AppStrings.saveAddress.tr()),
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