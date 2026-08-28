import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../app_constants/app_strings.dart';

class AuthRequiredBottomSheet extends StatelessWidget {
  const AuthRequiredBottomSheet({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              AppStrings.loginRequired.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              AppStrings.pleaseLoginOrRegisterToContinue.tr(),

              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogin,
                child:  Text(AppStrings.login.tr()),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRegister,
                child:  Text(AppStrings.register.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
