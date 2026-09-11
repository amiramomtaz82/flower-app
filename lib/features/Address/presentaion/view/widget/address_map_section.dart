// lib/features/Address/presentaion/view/widget/address_map_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddressMapSection extends StatefulWidget {
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;
  final VoidCallback? onLocateMePressed;
  final bool isLoadingLocation;

  const AddressMapSection({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
    this.onLocateMePressed,
    this.isLoadingLocation = false,
  });

  @override
  State<AddressMapSection> createState() => _AddressMapSectionState();
}

class _AddressMapSectionState extends State<AddressMapSection> {
  late final MapController _mapController;
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357); // Cairo default

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant AddressMapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLocation != null &&
        widget.selectedLocation != oldWidget.selectedLocation) {
      _mapController.move(widget.selectedLocation!, 15.0);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLocation = widget.selectedLocation ?? _defaultLocation;

    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: activeLocation,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (tapPosition, point) {
                  widget.onLocationSelected(point);
                  _mapController.move(point, _mapController.camera.zoom);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flower_app',
                ),
                if (widget.selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.selectedLocation!,
                        width: 42,
                        height: 42,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Color(0xFFD81B60), // Theme pink/red matching Figma
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // Floating GPS button matching location-services trigger
            if (widget.onLocateMePressed != null)
              Positioned(
                bottom: 10,
                right: 10,
                child: InkWell(
                  onTap: widget.isLoadingLocation ? null : widget.onLocateMePressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isLoadingLocation
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                        : const Icon(
                      Icons.my_location,
                      size: 22,
                      color: Color(0xFFD81B60),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}