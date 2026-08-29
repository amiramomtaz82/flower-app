import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  void _onMapTap(
      TapPosition tapPosition,
      LatLng point,
      ) {
    context.read<AddressCubit>().doEvents(
      SelectLocationEvent(point),
    );
  }

  // ============================================================
  // CURRENT LOCATION
  // ============================================================

  void _getCurrentLocation() {
    context.read<AddressCubit>().doEvents(
      GetCurrentLocationEvent(),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
      ),
      body: BlocListener<AddressCubit, AddressState>(
        listener: (context, state) {
          final location = state.selectedLocationDetails;

          if (location != null) {
            addressController.text = location.addressLine ?? '';
          }
        },
        child: BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            final cubit = context.read<AddressCubit>();

            // ============================================================
            // CITIES
            // ============================================================

            final cityMap = <String, CityEntity>{};

            for (final area in state.areas) {
              for (final city in area.cities) {
                if (city.id != null) {
                  cityMap[city.id!] = city;
                }
              }
            }

            final cities = cityMap.values.toList();

            // ============================================================
            // AREAS
            // ============================================================

            final areas = cubit.filteredAreas;

            // Make sure selected values actually exist in dropdown items.
            final selectedCity = state.selectedCity != null &&
                cities.any(
                      (city) => city.id == state.selectedCity!.id,
                )
                ? state.selectedCity
                : null;

            final selectedArea = state.selectedArea != null &&
                areas.any(
                      (area) => area.id == state.selectedArea!.id,
                )
                ? state.selectedArea
                : null;

            final selectedLocation = state.selectedLocation;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ======================================================
                  // MAP
                  // ======================================================

                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: const LatLng(
                              30.0131,
                              31.2089,
                            ),
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
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.location_pin,
                                      size: 45,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
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

                  // ======================================================
                  // LABEL
                  // ======================================================

                  TextFormField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Label Address',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // RECIPIENT NAME
                  // ======================================================

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Name',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // PHONE
                  // ======================================================

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // ADDRESS
                  // ======================================================

                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // CITY + AREA
                  // ======================================================

                  Row(
                    children: [
                      // ====================================================
                      // CITY DROPDOWN
                      // ====================================================

                      Expanded(
                        child: DropdownButtonFormField<CityEntity>(
                          initialValue: selectedCity,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'City',
                          ),

                          // Disable if there are no cities.
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

                      // ====================================================
                      // AREA DROPDOWN
                      // ====================================================

                      Expanded(
                        child: DropdownButtonFormField<AreaEntity>(
                          initialValue: selectedArea,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Area',
                          ),

                          // Areas are filtered according to selected city.
                          items: areas.map((area) {
                            return DropdownMenuItem<AreaEntity>(
                              value: area,
                              child: Text(
                                area.name ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),

                          // Disabled until a city is selected.
                          onChanged: selectedCity == null || areas.isEmpty
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
      ),
    );
  }


  // ============================================================
  // CITY DROPDOWN
  // ============================================================

  Widget _buildCityDropdown(
      BuildContext context,
      AddressState state,
      ) {
    final cities = <CityEntity>[];

    for (final area in state.areas) {
      cities.addAll(area.cities ?? []);
    }

    // Remove duplicate cities by ID.
    final uniqueCities = <String, CityEntity>{};

    for (final city in cities) {
      if (city.id != null) {
        uniqueCities[city.id!] = city;
      }
    }

    final cityList = uniqueCities.values.toList();

    final selectedCity = state.selectedCity;

    final selectedCityExists = selectedCity != null &&
        cityList.any(
              (city) => city.id == selectedCity.id,
        );

    return DropdownButtonFormField<CityEntity>(
      initialValue: selectedCityExists ? selectedCity : null,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'City',
      ),
      items: cityList.map((city) {
        return DropdownMenuItem<CityEntity>(
          value: city,
          child: Text(
            city.name ?? '',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (city) {
        if (city == null) return;

        context.read<AddressCubit>().doEvents(
          SelectCityEvent(city),
        );
      },
    );
  }

  // ============================================================
  // AREA DROPDOWN
  // ============================================================

  Widget _buildAreaDropdown(
      BuildContext context,
      AddressState state,
      ) {
    final selectedArea = state.selectedArea;

    /*
     * The selected area determines which cities belong to it.
     *
     * If your backend relationship is actually:
     *
     * Area -> Cities
     *
     * then we use state.selectedArea.cities here.
     */

    final areas = state.areas;

    final selectedAreaExists = selectedArea != null &&
        areas.any(
              (area) => area.id == selectedArea.id,
        );

    return DropdownButtonFormField<AreaEntity>(
      initialValue: selectedAreaExists ? selectedArea : null,
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
      onChanged: (area) {
        if (area == null) return;

        context.read<AddressCubit>().doEvents(
          SelectAreaEvent(area),
        );
      },
    );
  }

  // ============================================================
  // SAVE ADDRESS
  // ============================================================

  void _saveAddress(
      BuildContext context,
      AddressState state,
      ) {
    if (state.selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a location on the map',
          ),
        ),
      );

      return;
    }

    if (state.selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a city',
          ),
        ),
      );

      return;
    }

    if (state.selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an area',
          ),
        ),
      );

      return;
    }

    debugPrint('========== ADDRESS ==========');
    debugPrint('Name: ${nameController.text}');
    debugPrint('Phone: ${phoneController.text}');
    debugPrint('Address: ${addressController.text}');
    debugPrint('City: ${state.selectedCity?.name}');
    debugPrint('City ID: ${state.selectedCity?.id}');
    debugPrint('Area: ${state.selectedArea?.name}');
    debugPrint('Area ID: ${state.selectedArea?.id}');
    debugPrint(
      'Latitude: ${state.selectedLocation!.latitude}',
    );
    debugPrint(
      'Longitude: ${state.selectedLocation!.longitude}',
    );
    debugPrint('Label: ${labelController.text}');
    debugPrint('============================');
  }
}