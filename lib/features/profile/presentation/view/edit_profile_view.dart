import 'dart:io';

import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_cubit.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_event.dart';
import 'package:flower_app/features/profile/presentation/manager/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatefulWidget {
  final ProfileEntity? initialProfile;

  const EditProfileView({super.key, this.initialProfile});

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

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    final nameParts = (profile?.name ?? '').trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _passwordController = TextEditingController(text: '••••••••');
    _selectedGender = (profile?.gender?.isNotEmpty ?? false)
        ? profile!.gender!.toLowerCase()
        : 'female';
    _photoUrl = profile?.profileImageUrl ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final updateEntity = UpdateProfileEntity(
        fullName: fullName,
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender,
        photoUrl: _selectedImageFile?.path ?? _photoUrl,
      );

      context.read<ProfileCubit>().doEvent(UpdateProfile(updateEntity));
    }
  }

  // Upload image from gallery and return the file
  File? _selectedImageFile;
  Future<void> uploadImage() async {
    try {
      // debugPrint('📷 Camera tapped, launching gallery...');
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );
      // debugPrint('📷 Picked file: ${pickedFile?.path}');

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _photoUrl = pickedFile.path;
        });
      }
    } catch (e) {
      // debugPrint('🚨 Error picking image: $e');
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
        title: const Text(AppStrings.editProfile),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    size: 28,
                    color: Color(0xff0C1015),
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xffCC1010),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
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
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.updateProfileResource.status !=
            current.updateProfileResource.status,
        listener: (context, state) {
          final status = state.updateProfileResource.status;

          if (status == ApiStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppStrings.profileUpdatedSuccessfully),
                backgroundColor: colors.success,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (status == ApiStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.updateProfileResource.errorMessage ??
                      AppStrings.failedToUpdateProfile,
                ),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.updateProfileResource.isLoading;

          return Form(
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
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: colors.surface,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!)
                            : (_photoUrl.isNotEmpty
                                  ? NetworkImage(_photoUrl) as ImageProvider
                                  : null),
                        child: _selectedImageFile != null
                            ? null
                            : (_photoUrl.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 46,
                                      color: colors.white,
                                    )
                                  : null),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await uploadImage();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: colors.grey.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: Color(0xff535353),
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
                      child: _OutlinedProfileTextField(
                        label: 'First name',
                        controller: _firstNameController,
                        validator: Validation.validateName,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OutlinedProfileTextField(
                        label: 'Last name',
                        controller: _lastNameController,
                        validator: Validation.validateName,
                        keyboardType: TextInputType.name,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Email Field
                _OutlinedProfileTextField(
                  label: 'Email',
                  controller: _emailController,
                  validator: Validation.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                // Phone Number Field
                _OutlinedProfileTextField(
                  label: 'Phone number',
                  controller: _phoneController,
                  validator: Validation.validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),

                // Password Field with Change action
                _OutlinedProfileTextField(
                  label: 'Password',
                  controller: _passwordController,
                  readOnly: true,
                  obscureText: true,
                  suffix: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Change',
                      style: TextStyle(
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
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff535353),
                      ),
                    ),
                    const SizedBox(width: 24),
                    _GenderRadio(
                      label: 'Femail',
                      selected: _selectedGender == 'female',
                      color: colors.primary,
                      onTap: () => setState(() => _selectedGender = 'female'),
                    ),
                    const SizedBox(width: 24),
                    _GenderRadio(
                      label: 'Male',
                      selected: _selectedGender == 'male',
                      color: colors.primary,
                      onTap: () => setState(() => _selectedGender = 'male'),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OutlinedProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffix;

  const _OutlinedProfileTextField({
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>()!;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xff0C1015),
      ),
      decoration: InputDecoration(
        labelText: label,
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
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 8), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xff535353),
            ),
          ),
        ],
      ),
    );
  }
}
