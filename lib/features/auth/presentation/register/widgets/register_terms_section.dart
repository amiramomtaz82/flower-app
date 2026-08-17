import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterTermsSection extends StatefulWidget {
  const RegisterTermsSection({super.key});

  @override
  State<RegisterTermsSection> createState() => _RegisterTermsSectionState();
}

class _RegisterTermsSectionState extends State<RegisterTermsSection> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = () {};
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = () {
        context.go(AppRoutes.login);
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _loginRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            children: [
              TextSpan(text: 'terms_agreement'.tr()),
              TextSpan(
                text: 'terms_conditions'.tr(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  decoration: TextDecoration.underline,
                  decorationColor: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: _termsRecognizer,
              ),
            ],
          ),
        ),
        const SizedBox(height: 70),
        Center(
          child: RichText(
            text: TextSpan(
              style: textTheme.bodyMedium,
              children: [
                TextSpan(text: 'already_have_account'.tr()),
                TextSpan(
                  text: 'login'.tr(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: _loginRecognizer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
