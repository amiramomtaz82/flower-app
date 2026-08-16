import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/features/auth/data/models/register_request.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_event.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/core/widgets/custom_text_field.dart';
import 'package:flower_app/core/widgets/gender_option_widget.dart';
import 'package:flutter/gestures.dart';
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

  String selectedGender = 'Female';

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
          SignUpRequest(
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
        title: Text('Sign up', style: textTheme.titleLarge),
        centerTitle: false,
      ),
      body: BlocConsumer<RegisterViewModel, RegisterState>(
        listener: (context, state) {
          if (state.data != null) {
            context.go(AppRoutes.login);
          } else if (state.errMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errMessage),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final vm = context.read<RegisterViewModel>();
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First name',
                            hint: 'Enter first name',
                            controller: firstNameController,
                            validator: Validation.validateName,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last name',
                            hint: 'Enter last name',
                            controller: lastNameController,
                            validator: Validation.validateName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: emailController,
                      validator: Validation.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Password',
                            hint: 'Enter password',
                            controller: passwordController,
                            validator: Validation.validatePassword,
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Confirm password',
                            hint: 'Confirm password',
                            controller: confirmPasswordController,
                            validator: (value) =>
                                Validation.validateConfirmPassword(
                                  value,
                                  passwordController.text,
                                ),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Phone number',
                      hint: 'Enter phone number',
                      controller: phoneNumberController,
                      validator: Validation.validatePhoneNumber,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Text(
                          'Gender',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 24),
                        GenderOptionWidget(
                          label: 'Female',
                          selected: selectedGender == 'Female',
                          onTap: () =>
                              setState(() => selectedGender = 'Female'),
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        GenderOptionWidget(
                          label: 'Male',
                          selected: selectedGender == 'Male',
                          onTap: () => setState(() => selectedGender = 'Male'),
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms&Conditions',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => onSignUpPressed(vm),
                              child: const Text('Sign up'),
                            ),
                          ),
                    const SizedBox(height: 16),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.go(AppRoutes.login);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
