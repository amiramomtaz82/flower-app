import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppColors colors = LightColors();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        titleSpacing: 0,
        title: Text("login".tr()),
      ),

      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "enter your email".tr(),
                      labelText: "email".tr(),
                    ),
                    validator: Validation.validateEmail,
                    controller: emailController,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "enterYourPassword".tr(),
                      labelText: "password".tr(),
                    ),
                    validator: Validation.validatePassword,
                    controller: passwordController,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Icon(Icons.check_box_outline_blank_rounded),
                    SizedBox(width: 10),
                    Text("rememberMe".tr()),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      InkWell(onTap: (){
                        context.push(AppRoutes.forgotPassword);
                      },
                        child: Text(
                          "forget password".tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70),
                Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(onPressed: () {}, child: Text("login".tr())),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: OutlinedButton(style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromHeight(50)),
                    onPressed: () {},
                    child: Text("continueAsGuest".tr(),style: Theme.of(context).textTheme.bodyLarge,),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "dontHaveAnAccount".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      InkWell(onTap: (){
                        context.push(AppRoutes.register);
                      },
                        child: Text(
                          "signUp".tr(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
    );
  }
}
