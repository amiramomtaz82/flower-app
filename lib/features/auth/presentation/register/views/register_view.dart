import 'package:flower_app/config/resource/rsource.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_event.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flower_app/features/auth/presentation/register/widgets/register_form_fields.dart';
import 'package:flower_app/features/auth/presentation/register/widgets/register_gender_section.dart';
import 'package:flower_app/features/auth/presentation/register/widgets/register_terms_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  void onSignUpPressed(RegisterViewModel vm, RegisterState state) {
    if (_formKey.currentState!.validate()) {
      vm.doEvent(
        DoRegister(
          RegisterParams(
            firstName: state.firstName,
            lastName: state.lastName,
            email: state.email,
            password: state.password,
            confirmPassword: state.confirmPassword,
            phoneNumber: state.phoneNumber,
            gender: state.selectedGender,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final vm = context.read<RegisterViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onSurface),
        title: Text('sign_up'.tr(), style: textTheme.titleLarge),
        centerTitle: false,
      ),
      body: BlocListener<RegisterViewModel, RegisterState>(
        listenWhen: (previous, current) =>
            previous.status.status != current.status.status,
        listener: (context, state) {
          if (state.status.status == ApiStatus.success) {
            context.go(AppRoutes.home);
          } else if (state.status.status == ApiStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    state.status.errorMessage ?? 'registration_failed'.tr()),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RegisterFormFields(
                    onFirstNameChanged: (v) =>
                        vm.doEvent(UpdateField(firstName: v)),
                    onLastNameChanged: (v) =>
                        vm.doEvent(UpdateField(lastName: v)),
                    onEmailChanged: (v) => vm.doEvent(UpdateField(email: v)),
                    onPasswordChanged: (v) =>
                        vm.doEvent(UpdateField(password: v)),
                    onConfirmPasswordChanged: (v) =>
                        vm.doEvent(UpdateField(confirmPassword: v)),
                    onPhoneNumberChanged: (v) =>
                        vm.doEvent(UpdateField(phoneNumber: v)),
                    onPasswordValidated: () => _formKey.currentState?.validate(),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<RegisterViewModel, RegisterState>(
                    buildWhen: (previous, current) =>
                        previous.selectedGender != current.selectedGender,
                    builder: (context, state) {
                      return RegisterGenderSection(
                        selectedGender: state.selectedGender,
                        onChanged: (gender) =>
                            vm.doEvent(SelectGender(gender)),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const RegisterTermsSection(),
                  const SizedBox(height: 24),
                  BlocBuilder<RegisterViewModel, RegisterState>(
                    buildWhen: (previous, current) =>
                        previous.status.isLoading != current.status.isLoading,
                    builder: (context, state) {
                      if (state.status.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onSignUpPressed(vm, state),
                          child: Text('sign_up'.tr()),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
