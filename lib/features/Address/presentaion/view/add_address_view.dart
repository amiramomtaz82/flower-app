
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
    // Clean up singleton state so returning to this view starts fresh
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
      appBar: AppBar(
        title: const Text('Add Address'),
      ),
      body: BlocListener<AddressCubit, AddressState>(
        listenWhen: (previous, current) =>
        previous.selectedLocation != current.selectedLocation ||
            previous.selectedLocationDetails != current.selectedLocationDetails ||
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
              const SnackBar(
                content: Text('Address added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state.addAddressResource.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.addAddressResource.errorMessage ?? 'Failed to add address',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            // Area is parent, available cities depend on selected area
            final areas = state.areas;
            final availableCities = state.selectedArea?.cities ?? <CityEntity>[];

            final currentSelectedArea = state.selectedArea != null &&
                areas.any((a) => a.id == state.selectedArea!.id)
                ? state.selectedArea
                : null;

            final currentSelectedCity = state.selectedCity != null &&
                availableCities.any((c) => c.id == state.selectedCity!.id)
                ? state.selectedCity
                : null;

            final selectedLocation = state.selectedLocation;
            final isSaving = state.addAddressResource.isLoading;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ======================================================
                    // MAP
                    // ======================================================
                    SizedBox(
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
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.flower_app',
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
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Material(
                                elevation: 2,
                                shape: const CircleBorder(),
                                color: Colors.white,
                                child: IconButton(
                                  onPressed: _getCurrentLocation,
                                  icon: const Icon(Icons.my_location),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ======================================================
                    // LABEL
                    // ======================================================
                    TextFormField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label ',
                      ),
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter a label' : null,
                    ),

                    const SizedBox(height: 16),

                    // ======================================================
                    // RECIPIENT NAME
                    // ======================================================
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name',
                      ),
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter recipient name' : null,
                    ),

                    const SizedBox(height: 16),

                    // ======================================================
                    // PHONE
                    // ======================================================
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                      ),
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter phone number' : null,
                    ),

                    const SizedBox(height: 16),

                    // ======================================================
                    // ADDRESS LINE
                    // ======================================================
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address Details / Street',
                      ),
                      validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Please enter address details' : null,
                    ),

                    const SizedBox(height: 16),

                    // ======================================================
                    // AREA (PARENT) + CITY (CHILD) DROPDOWNS
                    // ======================================================
                    Row(
                      children: [
                        // Area Dropdown
                        Expanded(
                          child: DropdownButtonFormField<AreaEntity>(
                            key: ValueKey('area_${currentSelectedArea?.id ?? 'none'}'),
                            value: currentSelectedArea,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Area'),
                            hint: Text(areas.isEmpty ? 'Loading areas...' : 'Select Area'),
                            items: areas.map((area) {
                              return DropdownMenuItem<AreaEntity>(
                                value: area,
                                child: Text(
                                  area.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: areas.isEmpty
                                ? null
                                : (area) {
                              if (area != null) {
                                context.read<AddressCubit>().doEvents(SelectAreaEvent(area));
                              }
                            },
                            validator: (val) => val == null ? 'Select an area' : null,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // City Dropdown (Derived from chosen area)
                        Expanded(
                          child: DropdownButtonFormField<CityEntity>(
                            key: ValueKey('city_${currentSelectedCity?.id ?? 'none'}'),
                            value: currentSelectedCity,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'City'),
                            hint: Text(
                              currentSelectedArea == null
                                  ? 'Pick area first'
                                  : (availableCities.isEmpty ? 'No cities' : 'Select City'),
                            ),
                            items: availableCities.map((city) {
                              return DropdownMenuItem<CityEntity>(
                                value: city,
                                child: Text(
                                  city.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (currentSelectedArea == null || availableCities.isEmpty)
                                ? null
                                : (city) {
                              if (city != null) {
                                context.read<AddressCubit>().doEvents(SelectCityEvent(city));
                              }
                            },
                            validator: (val) => val == null ? 'Select a city' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // SAVE BUTTON
                    // ======================================================
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : () => _saveAddress(context, state),
                        child: isSaving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text('Save Address'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveAddress(BuildContext context, AddressState state) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (state.selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or pin a location on the map')),
      );
      return;
    }

    if (state.selectedArea?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an area')),
      );
      return;
    }

    if (state.selectedCity?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    final entity = AddAddressEntity(
      recipientName: nameController.text.trim(),
      recipientPhone: phoneController.text.trim(),
      addressLine: addressController.text.trim(),
      area: state.selectedArea!.id!,
      city: state.selectedCity!.id!,
      lat: state.selectedLocation!.latitude,
      lng: state.selectedLocation!.longitude,
      label: labelController.text.trim().isEmpty ? 'Home' : labelController.text.trim(),
    );

    context.read<AddressCubit>().doEvents(AddAddressEvent(entity));
  }
}