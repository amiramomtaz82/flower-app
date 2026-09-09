import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AddressMapSection extends StatelessWidget {
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const AddressMapSection({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: selectedLocation != null
            ? Text(
          AppStrings.coordinatesFormat.tr(namedArgs: {
            'lat': selectedLocation!.latitude.toStringAsFixed(4),
            'lng': selectedLocation!.longitude.toStringAsFixed(4),
          }),
          style: Theme.of(context).textTheme.bodyMedium,
        )
            : Text(
          AppStrings.tapMapToSelectLocation.tr(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}