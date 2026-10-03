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

  final ValueNotifier<bool> _isFormValidNotifier = ValueNotifier<bool>(false);

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

    _isFormValidNotifier.value = hasCurrent && hasNew && hasConfirm;
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_checkFormValidation);
    _newPasswordController.removeListener(_checkFormValidation);
    _confirmPasswordController.removeListener(_checkFormValidation);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _isFormValidNotifier.dispose();
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.white,
      appBar: AppBar(
        backgroundColor: colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppStrings.changePassword.tr(),
          style: textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.changePasswordResource != current.changePasswordResource,
        listener: (context, state) {
          if (state.changePasswordResource.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.passwordUpdatedSuccessfully.tr()),
                backgroundColor: colors.success,
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _OutlinedPasswordField(
                label: AppStrings.currentPassword.tr(),
                hint: AppStrings.currentPassword.tr(),
                controller: _currentPasswordController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _OutlinedPasswordField(
                label: AppStrings.newPassword.tr(),
                hint: AppStrings.newPassword.tr(),
                controller: _newPasswordController,
                validator: (value) {
                  final passwordErr = Validation.validatePassword(value);
                  if (passwordErr != null) return passwordErr;
                  if (value == _currentPasswordController.text) {
                    return 'New password must be different from current password';
                  }
                  return null;
                },
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
              BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: (previous, current) =>
                    previous.changePasswordResource.isLoading !=
                    current.changePasswordResource.isLoading,
                builder: (context, state) {
                  final isLoading = state.changePasswordResource.isLoading;

                  return ValueListenableBuilder<bool>(
                    valueListenable: _isFormValidNotifier,
                    builder: (context, isFormValid, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (isLoading || !isFormValid)
                              ? null
                              : _onUpdatePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            disabledBackgroundColor: colors.disabled,
                            foregroundColor: colors.white,
                            disabledForegroundColor: colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  AppStrings.update.tr(),
                                  style: textTheme.titleMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedPasswordField extends StatefulWidget {
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
  State<_OutlinedPasswordField> createState() => _OutlinedPasswordFieldState();
}

class _OutlinedPasswordFieldState extends State<_OutlinedPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      style: textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.grey.withValues(alpha: 0.8),
          fontSize: 14,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colors.grey,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        filled: true,
        fillColor: colors.white,
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
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
