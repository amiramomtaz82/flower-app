import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController phoneNumberController;
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final ValueChanged<String> onPhoneNumberChanged;

  const RegisterFormFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.phoneNumberController,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onPhoneNumberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'first_name'.tr(),
                hint: 'enter_first_name'.tr(),
                controller: firstNameController,
                validator: Validation.validateName,
                onChanged: onFirstNameChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'last_name'.tr(),
                hint: 'enter_last_name'.tr(),
                controller: lastNameController,
                validator: Validation.validateName,
                onChanged: onLastNameChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'email'.tr(),
          hint: 'enter_email'.tr(),
          controller: emailController,
          validator: Validation.validateEmail,
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'password'.tr(),
                hint: 'enter_password'.tr(),
                controller: passwordController,
                validator: Validation.validatePassword,
                obscureText: true,
                onChanged: onPasswordChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'confirm_password'.tr(),
                hint: 'confirm_password'.tr(),
                controller: confirmPasswordController,
                validator: (value) => Validation.validateConfirmPassword(
                  value,
                  passwordController.text,
                ),
                obscureText: true,
                onChanged: onConfirmPasswordChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'phone_number'.tr(),
          hint: 'enter_phone_number'.tr(),
          controller: phoneNumberController,
          validator: Validation.validatePhoneNumber,
          keyboardType: TextInputType.phone,
          onChanged: onPhoneNumberChanged,
        ),
      ],
    );
  }
}
