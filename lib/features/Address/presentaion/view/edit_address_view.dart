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

class EditAddressView extends StatefulWidget {
  const EditAddressView({super.key, required this.addressId});

  final String addressId;

  @override
  State<EditAddressView> createState() => _EditAddressViewState();
}

class _EditAddressViewState extends State<EditAddressView> {
  final MapController _mapController = MapController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController labelController = TextEditingController();

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<AddressCubit>();
    cubit.doEvents(const GetAreasWithCitiesEvent());
    cubit.doEvents(GetAddressByIdEvent(widget.addressId));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    labelController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    context.read<AddressCubit>().doEvents(SelectLocationEvent(point));
  }

  void _prefillIfReady(AddressState state) {
    if (_prefilled) return;

    final address = state.addressDetails;

    if (address == null ||
        address.id != widget.addressId ||
        state.cities.isEmpty) {
      return;
    }

    labelController.text = address.label ?? '';
    nameController.text = address.recipientName ?? '';
    phoneController.text = address.recipientPhone ?? '';
    addressController.text = address.addressLine ?? '';

    context.read<AddressCubit>().doEvents(
      PrefillAddressForEditEvent(address),
    );

    _prefilled = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit address')),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          _prefillIfReady(state);

          if (state.updateAddressResource.isSuccess) {
            context.pop();
          }
        },

        builder: (context, state) {
          final cubit = context.read<AddressCubit>();

          final cities = state.cities;
          final areas = cubit.filteredAreas;

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

          if (state.addressDetails?.id != widget.addressId &&
              state.getAddressByIdResource.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: selectedLocation ??
                          const LatLng(30.0131, 31.2089),
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
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
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

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CityEntity>(
                        initialValue: selectedCity,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: cities.map((city) {
                          return DropdownMenuItem<CityEntity>(
                            value: city,
                            child: Text(
                              city.name,
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
                        decoration: const InputDecoration(labelText: 'Area'),
                        items: areas.map((area) {
                          return DropdownMenuItem<AreaEntity>(
                            value: area,
                            child: Text(
                              area.name,
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.updateAddressResource.isLoading
                        ? null
                        : () => _saveAddress(context, state),
                    child: state.updateAddressResource.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
      city: state.selectedCity!.id,
      area: state.selectedArea!.id,
      lat: state.selectedLocation!.latitude,
      lng: state.selectedLocation!.longitude,
      label: labelController.text.trim(),
    );

    context.read<AddressCubit>().doEvents(
      UpdateAddressEvent(widget.addressId, address),
    );
  }
}
