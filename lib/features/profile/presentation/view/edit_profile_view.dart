import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/core/widgets/custom_text_field.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flower_app/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/services/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditProfileView extends StatefulWidget {
  final ProfileEntity? initialProfile;
  final ImagePickerService imagePickerService;

  EditProfileView({
    super.key,
    this.initialProfile,
    ImagePickerService? imagePickerService,
  }) : imagePickerService = imagePickerService ?? getIt<ImagePickerService>();

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  late String _selectedGender;
  late String _photoUrl;
  late final ValueNotifier<File?> _selectedImageNotifier;
  late final ValueNotifier<bool> _hasChangesNotifier;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;

    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _selectedGender = (profile?.gender?.isNotEmpty ?? false)
        ? profile!.gender!.toLowerCase()
        : 'female';
    _photoUrl = profile?.profileImageUrl ?? '';
    _selectedImageNotifier = ValueNotifier<File?>(null);
    _hasChangesNotifier = ValueNotifier<bool>(false);

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _selectedImageNotifier.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFieldChanged);
    _lastNameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _selectedImageNotifier.removeListener(_onFieldChanged);
    _hasChangesNotifier.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _selectedImageNotifier.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    _hasChangesNotifier.value = _computeHasChanges();
  }

  bool _computeHasChanges() {
    final profile = widget.initialProfile;
    final initialFirstName = profile?.firstName ?? '';
    final initialLastName = profile?.lastName ?? '';
    final initialEmail = profile?.email ?? '';
    final initialPhone = profile?.phoneNumber ?? '';
    final initialGender = (profile?.gender?.isNotEmpty ?? false)
        ? profile!.gender!.toLowerCase()
        : 'female';

    final isFirstNameChanged =
        _firstNameController.text.trim() != initialFirstName.trim();
    final isLastNameChanged =
        _lastNameController.text.trim() != initialLastName.trim();
    final isEmailChanged = _emailController.text.trim() != initialEmail.trim();
    final isPhoneChanged = _phoneController.text.trim() != initialPhone.trim();
    final isGenderChanged = _selectedGender.trim() != initialGender.trim();
    final isPhotoChanged = _selectedImageNotifier.value != null;

    return isFirstNameChanged ||
        isLastNameChanged ||
        isEmailChanged ||
        isPhoneChanged ||
        isGenderChanged ||
        isPhotoChanged;
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final updateEntity = UpdateProfileParams(
        fullName: fullName,
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        photoUrl: _selectedImageNotifier.value?.path ?? _photoUrl,
      );

      context.read<ProfileCubit>().doEvent(UpdateProfile(updateEntity));
    }
  }

  // Upload image from gallery and return the file
  Future<void> uploadImage() async {
    try {
      final pickedPath = await widget.imagePickerService.pickImageFromGallery();

      if (pickedPath != null) {
        _selectedImageNotifier.value = File(pickedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.errorPickingImage.tr())),
        );
      }
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
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppStrings.editProfile.tr()),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    size: 28,
                    color: colors.black,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '3',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.updateProfileResource.status !=
            current.updateProfileResource.status,
        listener: (context, state) {
          final status = state.updateProfileResource.status;

          if (status == ApiStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.profileUpdatedSuccessfully.tr()),
                backgroundColor: colors.success,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (status == ApiStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.updateProfileResource.errorMessage ??
                      AppStrings.failedToUpdateProfile.tr(),
                ),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              const SizedBox(height: 8),

              // ------------- Avatar with Camera Icon Overlay -------------------
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ValueListenableBuilder<File?>(
                      valueListenable: _selectedImageNotifier,
                      builder: (context, imageFile, _) {
                        return ProfileAvatar(
                          radius: 46,
                          imageUrl: _photoUrl,
                          imageFile: imageFile,
                          backgroundColor: colors.surface,
                          iconColor: colors.white,
                        );
                      },
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: uploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: colors.black.withValues(alpha: 0.12),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: colors.grey.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: colors.darkGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ----------------------------------------------------------------
              const SizedBox(height: 28),

              // First Name and Last Name Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.firstName.tr(),
                      controller: _firstNameController,
                      validator: Validation.validateName,
                      keyboardType: TextInputType.name,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: AppStrings.lastName.tr(),
                      controller: _lastNameController,
                      validator: Validation.validateName,
                      keyboardType: TextInputType.name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Email Field
              CustomTextField(
                label: AppStrings.emailLabel.tr(),
                controller: _emailController,
                validator: Validation.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              // Phone Number Field
              CustomTextField(
                label: AppStrings.phoneNumber.tr(),
                controller: _phoneController,
                validator: Validation.validatePhoneNumber,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),

              // Password Field with Change action
              CustomTextField(
                label: AppStrings.passwordLabel.tr(),
                controller: _passwordController,
                readOnly: true,
                hint: '••••••••',
                hintStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.black,
                  letterSpacing: 2.0,
                ),
                onTap: () {
                  context.push(AppRoutes.changePassword);
                },
                suffix: TextButton(
                  onPressed: () {
                    context.push(AppRoutes.changePassword);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.change.tr(),
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Gender Section
              Row(
                children: [
                  Text(
                    AppStrings.gender.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.darkGrey,
                    ),
                  ),
                  const SizedBox(width: 24),
                  _GenderRadio(
                    label: AppStrings.female.tr(),
                    selected: _selectedGender == 'female',
                    color: colors.primary,
                    onTap: () {
                      if (_selectedGender != 'female') {
                        setState(() => _selectedGender = 'female');
                        _onFieldChanged();
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  _GenderRadio(
                    label: AppStrings.male.tr(),
                    selected: _selectedGender == 'male',
                    color: colors.primary,
                    onTap: () {
                      if (_selectedGender != 'male') {
                        setState(() => _selectedGender = 'male');
                        _onFieldChanged();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Update Button
              BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: (previous, current) =>
                    previous.updateProfileResource.isLoading !=
                    current.updateProfileResource.isLoading,
                builder: (context, state) {
                  final isLoading = state.updateProfileResource.isLoading;

                  return ValueListenableBuilder<bool>(
                    valueListenable: _hasChangesNotifier,
                    builder: (context, hasChanges, _) {
                      final isButtonEnabled = !isLoading && hasChanges;

                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isButtonEnabled ? _onSavePressed : null,
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
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  AppStrings.update.tr(),
                                  style: textTheme.bodyLarge?.copyWith(
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderRadio extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GenderRadio({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
