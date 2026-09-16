// lib/features/checkout/presentation/view/widget/checkout_gift_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';

class CheckoutGiftSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const CheckoutGiftSection({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
  });

  bool _isCash(String? method) {
    if (method == null) return false;
    final normalized = method.trim().toLowerCase();
    return normalized == 'cash' || normalized == 'cod' || normalized.contains('cash');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final colors = Theme.of(context).extension<AppColors>();
    final primaryColor = colors?.primary ?? const Color(0xFFD81B60);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen: (prev, curr) =>
      prev.isGift != curr.isGift || prev.paymentMethod != curr.paymentMethod,
      builder: (context, state) {
        final isCash = _isCash(state.paymentMethod);

        // Figma shows the gift section when applicable (e.g. Card selected)
        if (isCash) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Figma Header: Switch on the left + "It is a gift"
              Row(
                children: [
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: state.isGift,
                      activeColor: Colors.white,
                      activeTrackColor: primaryColor,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) => cubit.doEvents(ToggleGiftEvent(val)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "It is a gift",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Inputs visible only when switch is active
              if (state.isGift) ...[
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.name.tr(),
                          hintText: AppStrings.enterRecipientName.tr(),
                          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                        validator: Validation.validateName,
                        onChanged: (name) => cubit.doEvents(UpdateGiftDetailsEvent(name: name)),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: AppStrings.phoneNumber.tr(),
                          hintText: AppStrings.enterRecipientPhone.tr(),
                          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                        validator: Validation.validatePhoneNumber,
                        onChanged: (phone) => cubit.doEvents(UpdateGiftDetailsEvent(phone: phone)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}