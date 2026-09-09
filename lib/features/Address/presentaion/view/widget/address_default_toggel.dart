import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';

class AddressDefaultToggle extends StatelessWidget {
  final bool isDefault;
  final ValueChanged<bool> onChanged;

  const AddressDefaultToggle({
    super.key,
    required this.isDefault,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        AppStrings.setAsDefaultAddress.tr(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: isDefault,
      onChanged: onChanged,
    );
  }
}