import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/Address/presentaion/view/widget/app_validator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/add_address_entity.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/city_entity.dart';
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
  final MapController _mapController = MapController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressCubit>().doEvents(const GetAreasWithCitiesEvent());
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    labelController.dispose();
    context.read<AddressCubit>().doEvents(const ResetAddAddressStateEvent());
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    context.read<AddressCubit>().doEvents(SelectLocationEvent(point));
  }

  void _getCurrentLocation() {
    context.read<AddressCubit>().doEvents(const GetCurrentLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.addAddress.tr())),
      body: BlocListener<AddressCubit, AddressState>(
        listenWhen: (previous, current) =>
            previous.selectedLocation != current.selectedLocation ||
            previous.selectedLocationDetails !=
                current.selectedLocationDetails ||
            previous.addAddressResource != current.addAddressResource,
        listener: (context, state) {
          final location = state.selectedLocationDetails;
          if (location != null && (location.addressLine?.isNotEmpty ?? false)) {
            addressController.text = location.addressLine!;
          }

          if (state.selectedLocation != null) {
            _mapController.move(state.selectedLocation!, 15.0);
          }

          if (state.addAddressResource.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.addressAddedSuccessfully.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state.addAddressResource.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.addAddressResource.errorMessage ??
                      AppStrings.failedToAddAddress.tr(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ======================================================
                // MAP SECTION (Rebuilds only on Location & Geo Loading)
                // ======================================================
                BlocBuilder<AddressCubit, AddressState>(
                  buildWhen: (previous, current) =>
                      previous.selectedLocation != current.selectedLocation ||
                      previous.locationDetailsResource !=
                          current.locationDetailsResource,
                  builder: (context, state) {
                    final selectedLocation = state.selectedLocation;
                    final isResolvingLocation =
                        state.locationDetailsResource.isLoading;

                    return SizedBox(
                      height: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: const LatLng(30.0131, 31.2089),
                                initialZoom: 13,
                                onTap: _onMapTap,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.flower_app',
                                ),
                                if (selectedLocation != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: selectedLocation,
                                        width: 45,
                                        height: 45,
                                        child: Icon(
                                          Icons.location_pin,
                                          size: 45,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            if (isResolvingLocation)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Material(
                                elevation: 2,
                                shape: const CircleBorder(),
                                color: Colors.white,
                                child: IconButton(
                                  onPressed: isResolvingLocation
                                      ? null
                                      : _getCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ======================================================
                // STATIC FORM INPUTS (No BlocBuilder Rebuilds Needed)
                // ======================================================
                TextFormField(
                  controller: labelController,
                  decoration: InputDecoration(labelText: AppStrings.label.tr()),
                  validator: AppValidators.validateLabel,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.recipientName.tr(),
                  ),
                  validator: AppValidators.validateRecipientName,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppStrings.phoneNumber.tr(),
                  ),
                  validator: AppValidators.validatePhone,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: AppStrings.addressDetailsStreet.tr(),
                  ),
                  validator: AppValidators.validateAddressDetails,
                ),

                const SizedBox(height: 16),

                // ======================================================
                // AREA + CITY DROPDOWNS (Rebuilds only on Area/City State)
                // ======================================================
                BlocBuilder<AddressCubit, AddressState>(
                  buildWhen: (previous, current) =>
                      previous.areas != current.areas ||
                      previous.areasResource != current.areasResource ||
                      previous.selectedArea != current.selectedArea ||
                      previous.selectedCity != current.selectedCity,
                  builder: (context, state) {
                    final areas = state.areas;
                    final availableCities =
                        state.selectedArea?.cities ?? <CityEntity>[];

                    final currentSelectedArea =
                        state.selectedArea != null &&
                            areas.any((a) => a.id == state.selectedArea!.id)
                        ? state.selectedArea
                        : null;

                    final currentSelectedCity =
                        state.selectedCity != null &&
                            availableCities.any(
                              (c) => c.id == state.selectedCity!.id,
                            )
                        ? state.selectedCity
                        : null;

                    final isAreasLoading = state.areasResource.isLoading;

                    return Row(
                      children: [
                        // 1. Area Dropdown
                        Expanded(
                          child: DropdownButtonFormField<AreaEntity>(
                            key: ValueKey(
                              'area_${currentSelectedArea?.id ?? 'none'}',
                            ),
                            value: currentSelectedArea,
                            // ✅ Use value instead of initialValue
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: AppStrings.area.tr(),
                            ),
                            hint: Text(
                              isAreasLoading
                                  ? AppStrings.loadingAreas.tr()
                                  : AppStrings.selectArea.tr(),
                            ),
                            items: areas.map((area) {
                              return DropdownMenuItem<AreaEntity>(
                                value: area,
                                child: Text(
                                  area.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: isAreasLoading
                                ? null
                                : (area) {
                                    if (area != null) {
                                      context.read<AddressCubit>().doEvents(
                                        SelectAreaEvent(area),
                                      );
                                    }
                                  },
                            validator: (val) => AppValidators.validateSelection(
                              val,
                              AppStrings.pleaseSelectArea.tr(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 2. City Dropdown
                        Expanded(
                          child: DropdownButtonFormField<CityEntity>(
                            key: ValueKey('city_${currentSelectedCity?.id ?? 'none'}'),
                            value: currentSelectedCity, // ✅ Use value instead of initialValue
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: AppStrings.city.tr(),
                            ),
                            hint: Text(
                              currentSelectedArea == null
                                  ? AppStrings.pickAreaFirst.tr()
                                  : (availableCities.isEmpty
                                  ? AppStrings.noCities.tr()
                                  : AppStrings.selectCity.tr()),
                            ),
                            items: availableCities.map((city) {
                              return DropdownMenuItem<CityEntity>(
                                value: city,
                                child: Text(
                                  city.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (currentSelectedArea == null ||
                                availableCities.isEmpty)
                                ? null
                                : (city) {
                              if (city != null) {
                                context
                                    .read<AddressCubit>()
                                    .doEvents(SelectCityEvent(city));
                              }
                            },
                            validator: (val) => AppValidators.validateSelection(
                              val,
                              AppStrings.pleaseSelectCity.tr(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ======================================================
                // SAVE BUTTON (Rebuilds only on Add Address Request State)
                // ======================================================
                BlocBuilder<AddressCubit, AddressState>(
                  buildWhen: (previous, current) =>
                      previous.addAddressResource != current.addAddressResource,
                  builder: (context, state) {
                    final isSaving = state.addAddressResource.isLoading;

                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () => _saveAddress(context),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
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
    );
  }

  void _saveAddress(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cubitState = context.read<AddressCubit>().state;

    if (cubitState.selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectLocationOnMap.tr())),
      );
      return;
    }

    if (cubitState.selectedArea?.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.pleaseSelectArea.tr())));
      return;
    }

    if (cubitState.selectedCity?.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.pleaseSelectCity.tr())));
      return;
    }

    final entity = AddAddressEntity(
      recipientName: nameController.text.trim(),
      recipientPhone: phoneController.text.trim(),
      addressLine: addressController.text.trim(),
      area: cubitState.selectedArea!.id,
      city: cubitState.selectedCity!.id,
      lat: cubitState.selectedLocation!.latitude,
      lng: cubitState.selectedLocation!.longitude,
      label: labelController.text.trim().isEmpty
          ? AppStrings.defaultLabelHome.tr()
          : labelController.text.trim(),
    );

    context.read<AddressCubit>().doEvents(AddAddressEvent(entity));
  }
}
