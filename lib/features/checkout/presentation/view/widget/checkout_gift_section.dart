import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/checkout_cubit.dart';
import '../../manager/checkout_event.dart';
import '../../manager/checkout_state.dart';

class CheckoutGiftSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const CheckoutGiftSection({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        buildWhen: (prev, curr) =>
        prev.isGift != curr.isGift ||
            prev.selectedPaymentMethod != curr.selectedPaymentMethod ||
            prev.recipientName != curr.recipientName ||
            prev.recipientPhone != curr.recipientPhone,
        builder: (context, state) {
          final cubit = context.read<CheckoutCubit>();
          final isCash = state.selectedPaymentMethod?.toUpperCase() == 'COD';

          // Gifts are not permitted for cash on delivery
          if (isCash) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.isGift.tr(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Switch(
                    value: state.isGift,
                    onChanged: (value) => cubit.doEvents(ToggleGiftEvent(value)),
                  ),
                ],
              ),
              if (state.isGift) ...[
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        key: ValueKey(
                          '${AppStrings.recipientName}_${state.recipientName == null ? "empty" : "filled"}',
                        ),
                        initialValue: state.recipientName ?? '',
                        decoration: InputDecoration(
                          hintText: AppStrings.enterRecipientName.tr(),
                          labelText: AppStrings.name.tr(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: Validation.validateName,
                        onChanged: (name) =>
                            cubit.doEvents(UpdateGiftDetailsEvent(name: name)),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: ValueKey(
                          '${AppStrings.phoneNumber}_${state.recipientPhone == null ? "empty" : "filled"}',
                        ),
                        initialValue: state.recipientPhone ?? '',
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: AppStrings.enterRecipientPhone.tr(),
                          labelText: AppStrings.phoneNumber.tr(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: Validation.validatePhoneNumber,
                        onChanged: (phone) =>
                            cubit.doEvents(UpdateGiftDetailsEvent(phone: phone)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}