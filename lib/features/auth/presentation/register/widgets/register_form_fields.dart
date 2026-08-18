import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/core/widgets/custom_text_field.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterFormFields extends StatefulWidget {
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;
  final ValueChanged<String> onPhoneNumberChanged;
  final VoidCallback onPasswordValidated;

  const RegisterFormFields({
    super.key,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.onPhoneNumberChanged,
    required this.onPasswordValidated,
  });

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  // We need to keep a reference to the password for the confirm password validator
  String _currentPassword = '';

  @override
  Widget build(BuildContext context) {
    // Initial values are taken from state once, then managed internally by TextFormField
    // But MVI still holds because onChanged updates the state.
    final vm = context.read<RegisterViewModel>();
    final state = vm.state;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'first_name'.tr(),
                hint: 'enter_first_name'.tr(),
                validator: Validation.validateName,
                onChanged: widget.onFirstNameChanged,
                initialValue: state.firstName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'last_name'.tr(),
                hint: 'enter_last_name'.tr(),
                validator: Validation.validateName,
                onChanged: widget.onLastNameChanged,
                initialValue: state.lastName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'email'.tr(),
          hint: 'enter_email'.tr(),
          validator: Validation.validateEmail,
          keyboardType: TextInputType.emailAddress,
          onChanged: widget.onEmailChanged,
          initialValue: state.email,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'password'.tr(),
                hint: 'enter_password'.tr(),
                validator: Validation.validatePassword,
                obscureText: true,
                onChanged: (val) {
                  _currentPassword = val;
                  widget.onPasswordChanged(val);
                  widget.onPasswordValidated();
                },
                initialValue: state.password,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'confirm_password'.tr(),
                hint: 'confirm_password'.tr(),
                validator: (value) => Validation.validateConfirmPassword(
                  value,
                  _currentPassword,
                ),
                obscureText: true,
                onChanged: widget.onConfirmPasswordChanged,
                initialValue: state.confirmPassword,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'phone_number'.tr(),
          hint: 'enter_phone_number'.tr(),
          validator: Validation.validatePhoneNumber,
          keyboardType: TextInputType.phone,
          onChanged: widget.onPhoneNumberChanged,
          initialValue: state.phoneNumber,
        ),
      ],
    );
  }
}
