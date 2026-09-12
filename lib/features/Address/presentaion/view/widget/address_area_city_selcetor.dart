// lib/features/Address/presentaion/view/widget/address_area_city_selcetor.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/area_entity.dart';
import '../../../domain/entities/city_entity.dart';

class AddressAreaCitySelectors extends StatelessWidget {
  final List<AreaEntity> areas;
  final AreaEntity? selectedArea;
  final List<CityEntity> availableCities;
  final CityEntity? selectedCity;
  final ValueChanged<AreaEntity?> onAreaChanged;
  final ValueChanged<CityEntity?> onCityChanged;

  const AddressAreaCitySelectors({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.availableCities,
    required this.selectedCity,
    required this.onAreaChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<AreaEntity>(
            value: selectedArea,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppStrings.area.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: areas.map((area) {
              return DropdownMenuItem<AreaEntity>(
                value: area,
                child: Text(area.name ?? '', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onAreaChanged,
            validator: (val) => val == null ? AppStrings.pleaseSelectArea.tr() : null,
          ),
        ),const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<CityEntity>(
            value: selectedCity,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppStrings.city.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: availableCities.map((city) {
              return DropdownMenuItem<CityEntity>(
                value: city,
                child: Text(city.name ?? '', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onCityChanged,
            validator: (val) => val == null ? AppStrings.pleaseSelectCity.tr() : null,
          ),
        ),


        // Area Selector (Right)

      ],
    );
  }
}