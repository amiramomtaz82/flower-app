import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_checkFormValidation);
    _newPasswordController.addListener(_checkFormValidation);
    _confirmPasswordController.addListener(_checkFormValidation);
  }

  void _checkFormValidation() {
    final hasCurrent = _currentPasswordController.text.isNotEmpty;
    final hasNew = _newPasswordController.text.isNotEmpty;
    final hasConfirm = _confirmPasswordController.text.isNotEmpty;

    final isValid = hasCurrent && hasNew && hasConfirm;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final entity = ChangePasswordParams(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      context.read<ProfileCubit>().doEvent(ChangePasswordEvent(entity));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xff0C1015),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.changePassword.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff0C1015),
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.changePasswordResource != current.changePasswordResource,
        listener: (context, state) {
          if (state.changePasswordResource.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.passwordUpdatedSuccessfully.tr()),
                backgroundColor: const Color(0xff0CB359),
              ),
            );
            Navigator.of(context).pop();
          } else if (state.changePasswordResource.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.changePasswordResource.errorMessage ??
                      AppStrings.failedToUpdatePassword.tr(),
                ),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.changePasswordResource.isLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _OutlinedPasswordField(
                  label: AppStrings.currentPassword.tr(),
                  hint: AppStrings.currentPassword.tr(),
                  controller: _currentPasswordController,
                  validator: Validation.validatePassword,
                ),
                const SizedBox(height: 20),
                _OutlinedPasswordField(
                  label: AppStrings.newPassword.tr(),
                  hint: AppStrings.newPassword.tr(),
                  controller: _newPasswordController,
                  validator: Validation.validatePassword,
                ),
                const SizedBox(height: 20),
                _OutlinedPasswordField(
                  label: AppStrings.confirmPassword.tr(),
                  hint: AppStrings.confirmPassword.tr(),
                  controller: _confirmPasswordController,
                  validator: (value) => Validation.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isLoading || !_isFormValid)
                        ? null
                        : _onUpdatePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      disabledBackgroundColor: const Color(0xff878787),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            AppStrings.update.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OutlinedPasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _OutlinedPasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: true,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xff0C1015),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.grey.withValues(alpha: 0.8),
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: colors.darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        errorStyle: TextStyle(
          color: colors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
