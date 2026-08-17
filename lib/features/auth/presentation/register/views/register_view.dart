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
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void onSignUpPressed(RegisterViewModel vm, RegisterState state) {
    if (_formKey.currentState!.validate()) {
      vm.doEvent(
        DoRegister(
          RegisterParams(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
            phoneNumber: phoneNumberController.text.trim(),
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

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onSurface),
        title: Text('sign_up'.tr(), style: textTheme.titleLarge),
        centerTitle: false,
      ),
      body: BlocListener<RegisterViewModel, RegisterState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isSuccess) {
            context.go(AppRoutes.home);
          } else if (state.status.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.status.errorMessage ?? 'registration_failed'.tr()),
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
                    firstNameController: firstNameController,
                    lastNameController: lastNameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    phoneNumberController: phoneNumberController,
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<RegisterViewModel, RegisterState>(
                    buildWhen: (previous, current) =>
                        previous.selectedGender != current.selectedGender,
                    builder: (context, state) {
                      return RegisterGenderSection(
                        selectedGender: state.selectedGender,
                        onChanged: (gender) {
                          context.read<RegisterViewModel>().doEvent(SelectGender(gender));
                        },
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
                          onPressed: () => onSignUpPressed(
                              context.read<RegisterViewModel>(), state),
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
