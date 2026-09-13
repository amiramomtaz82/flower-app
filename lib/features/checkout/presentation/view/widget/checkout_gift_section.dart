import 'package:flower_app/core/app_constants/app_strings.dart';
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

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      buildWhen: (prev, curr) =>
      prev.isGift != curr.isGift || prev.paymentMethod != curr.paymentMethod,
      builder: (context, state) {
        final isCash = _isCash(state.paymentMethod);
        if (isCash || !state.isGift) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterRecipientName,
                    labelText: AppStrings.name,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: Validation.validateName,
                  onChanged: (name) => cubit.doEvents(UpdateGiftDetailsEvent(name: name)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: AppStrings.enterRecipientPhone,
                    labelText: AppStrings.phoneNumber,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: Validation.validatePhoneNumber,
                  onChanged: (phone) => cubit.doEvents(UpdateGiftDetailsEvent(phone: phone)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}