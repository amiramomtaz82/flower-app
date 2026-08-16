import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_events.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  GlobalKey<FormState> formKey = GlobalKey();
 final TextEditingController emailController = TextEditingController();
 final TextEditingController passwordController = TextEditingController();


  @override
  void dispose() {
    // TODO: implement dispose

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

@override
void initState() {
  super.initState();




}
  @override
  Widget build(BuildContext context) {
    AppColors colors = LightColors();
    LoginCubit cubit=context.read<LoginCubit>();


    return BlocListener<LoginCubit,LoginState>(listener: (context,state){

      if(state.loginResource.isError){
        ScaffoldMessenger.of(context).showSnackBar
          (SnackBar(content:Text(state.loginResource.errorMessage??"")));
      }

      if(state.loginResource.isSuccess){

        context.pushReplacement(AppRoutes.home);
      }
    },
        



            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                titleSpacing: 0,
                title: Text(AppStrings.login.tr()),
              ),

              body: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(

                            decoration: InputDecoration(
                              hintText: AppStrings.enterYourEmail.tr(),
                              labelText: AppStrings.email.tr(),
                            ),
                            onChanged: (value){
                              cubit.doEvents(EmailChanged(value));
                            },
                            validator: Validation.validateEmail,
                            controller: emailController,
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            obscureText: cubit.state.obscurePassword,
                            decoration: InputDecoration(
                              hintText: AppStrings.enterYourPassword.tr(),
                              labelText: AppStrings.password.tr(),suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  cubit.state.obscurePassword = !cubit.state.obscurePassword;
                                });
                              },
                              icon: Icon(
                                cubit.state.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            ),


                            validator: Validation.validatePassword,
                            onChanged: (value){
                              cubit.doEvents(PasswordChanged(value));
                            },
                            controller: passwordController,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            SizedBox(width: 15),
                            Icon(Icons.check_box_outline_blank_rounded),
                            SizedBox(width: 10),
                            Text(AppStrings.rememberMe.tr()),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                              InkWell(onTap: () {
                                context.push(AppRoutes.forgotPassword);
                              },
                                child: Text(
                                  AppStrings.forgetPassword.tr(),
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 70),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: BlocBuilder<LoginCubit,LoginState>(
                            builder: (context,state) {
                              return ElevatedButton(

                                  onPressed: state.loginResource.isLoading
                                  ? null
                                  : () {
                                                      if (formKey.currentState!.validate()) {
                                                      cubit.doEvents(LoginSubmitted());
                                                      }
                                                      },
                              child: state.loginResource.isLoading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(AppStrings.login.tr()),
                                                      );
                            }
                          ),




                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: OutlinedButton(style: OutlinedButton.styleFrom(
                              fixedSize: const Size.fromHeight(50)),
                            onPressed: () {
                            context.push(AppRoutes.home);
                            },
                            child: Text(AppStrings.continueAsGuest.tr(), style: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge,),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Row(mainAxisAlignment: MainAxisAlignment
                              .center,
                            children: [
                              Text(
                                AppStrings.dontHaveAnAccount.tr(),
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyLarge,
                              ),
                              InkWell(onTap: () {
                                context.push(AppRoutes.register);
                              },
                                child: Text(
                                  AppStrings.signUp.tr(),
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                    color: colors.error,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            );
          }


    
  }
