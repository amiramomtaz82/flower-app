// lib/features/Address/presentaion/view/widget/adress_form_fileds.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/validation/validation.dart';

class AddressFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressLineController;
  final TextEditingController labelController;

  const AddressFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressLineController,
    required this.labelController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: labelController,
          decoration: InputDecoration(
            labelText: AppStrings.label.tr(),
            hintText: AppStrings.label.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (val) =>
          (val == null || val.trim().isEmpty) ? AppStrings.addLabelTitle.tr() : null,
        ),

        const SizedBox(height: 16),



        // 3. Recipient Name (Third in Figma)
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppStrings.recipientName.tr(),
            hintText: AppStrings.recipientName.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: Validation.validateName,
        ),

        const SizedBox(height: 16),

        // 2. Phone Number (Second in Figma)
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppStrings.phoneNumber.tr(),
            hintText: AppStrings.phoneNumber.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: Validation.validatePhoneNumber,
        ),
        const SizedBox(height: 16),

        //  Label (Home / Work)
        TextFormField(
          controller: addressLineController,
          decoration: InputDecoration(
            labelText: AppStrings.address.tr(),
            hintText: AppStrings.address.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (val) =>
          (val == null || val.trim().isEmpty) ? AppStrings.addressDetailsRequired.tr() : null,
        ),
      ],
    );
  }
}