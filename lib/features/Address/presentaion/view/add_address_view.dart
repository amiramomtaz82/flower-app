import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final MapController _mapController = MapController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<AddressCubit>().doEvents(const InitializeAddressEvent());
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    labelController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAP TAP
  // ============================================================

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    context.read<AddressCubit>().doEvents(SelectLocationEvent(point));
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  void _getCurrentLocation() {
    context.read<AddressCubit>().doEvents(GetCurrentLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Address')),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          final location = state.selectedLocationDetails;

          if (location != null) {
            addressController.text = location.addressLine ?? '';
          }
        },

        builder: (context, state) {
          final cubit = context.read<AddressCubit>();
          debugPrint('========== DROPDOWN STATE ==========');
          debugPrint('state.areas = ${state.areas.length}');
          debugPrint('state.selectedArea = ${state.selectedArea?.name}');
          debugPrint('state.selectedCity = ${state.selectedCity?.name}');
          debugPrint('cubit.filteredAreas = ${cubit.filteredAreas.length}');
          debugPrint('cubit.filteredCities = ${cubit.filteredCities.length}');

          for (final area in state.areas) {
            debugPrint('AREA: ${area.name}, cities=${area.cities.length}');
          }
          debugPrint('====================================');

          final areas = state.areas;
          final cities = cubit.filteredCities;

          // Make sure selected values actually exist in dropdown items.
          final selectedCity =
              state.selectedCity != null &&
                  cities.any((city) => city.id == state.selectedCity!.id)
              ? state.selectedCity
              : null;

          final selectedArea =
              state.selectedArea != null &&
                  areas.any((area) => area.id == state.selectedArea!.id)
              ? state.selectedArea
              : null;

          final selectedLocation = state.selectedLocation;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                //======================= MAP
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(30.0131, 31.2089),
                          initialZoom: 13,
                          onTap: _onMapTap,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.flower_app',
                          ),

                          if (selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedLocation,
                                  width: 50,
                                  height: 50,
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

                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: labelController,
                  decoration: const InputDecoration(labelText: 'Label Address'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Name',
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),

                const SizedBox(height: 24),

                // CITY + AREA
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CityEntity>(
                        initialValue: selectedCity,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'City',
                        ),
                        items: cities.map((city) {
                          return DropdownMenuItem<CityEntity>(
                            value: city,
                            child: Text(
                              city.name ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: cities.isEmpty
                            ? null
                            : (city) {
                          if (city == null) return;

                          context.read<AddressCubit>().doEvents(
                            SelectCityEvent(city),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DropdownButtonFormField<AreaEntity>(
                        initialValue: selectedArea,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Area',
                        ),
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
                          if (area == null) return;

                          context.read<AddressCubit>().doEvents(
                            SelectAreaEvent(area),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ======================================================
                // SAVE
                // ======================================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveAddress(context, state);
                    },
                    child: const Text('Save Address'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SAVE ADDRESS
  // ============================================================

  void _saveAddress(BuildContext context, AddressState state) {
    if (state.selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );

      return;
    }

    if (state.selectedCity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a city')));

      return;
    }

    if (state.selectedArea == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an area')));

      return;
    }
    final address = AddAddressEntity(
      recipientName: nameController.text.trim(),
      recipientPhone: phoneController.text.trim(),
      addressLine: addressController.text.trim(),
      city: state.selectedCity!.name!,
      area: state.selectedArea!.name!,
      lat: state.selectedLocation!.latitude,
      lng: state.selectedLocation!.longitude,
      label: labelController.text.trim(),
    );

    context.read<AddressCubit>().doEvents(
      AddAddressEvent(address),
    ); // AddAddressEntity expects names, not IDs city: state.selectedCity!.name!, area: state.selectedArea!.name!, lat: state.selectedLocation!.latitude, lng: state.selectedLocation!.longitude, label: labelController.text.trim(), ); context.read<AddressCubit>().doEvents( AddAddressEvent(address), );
  }
}
