import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';
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

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterViewModel>(),
      child: const _RegisterBody(),
    );
  }
}

class _RegisterBody extends StatefulWidget {
  const _RegisterBody();

  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController phoneNumberController;

  Gender selectedGender = Gender.female;

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

  void onSignUpPressed(RegisterViewModel vm) {
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
            gender: selectedGender,
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
        listener: (context, state) {
          if (state.isSuccess) {
            context.go(AppRoutes.login);
          } else if (state.isError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'registration_failed'.tr()),
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
                  RegisterGenderSection(
                    selectedGender: selectedGender,
                    onChanged: (gender) {
                      setState(() {
                        selectedGender = gender;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const RegisterTermsSection(),
                  const SizedBox(height: 24),
                  BlocBuilder<RegisterViewModel, RegisterState>(
                    buildWhen: (previous, current) =>
                        previous.isLoading != current.isLoading,
                    builder: (context, state) {
                      if (state.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              onSignUpPressed(context.read<RegisterViewModel>()),
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
