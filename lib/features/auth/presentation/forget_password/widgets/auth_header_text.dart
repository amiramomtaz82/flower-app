import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthHeaderText extends StatelessWidget {
  const AuthHeaderText({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title.tr(), style: appTheme.textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(
          subtitle.tr(),
          textAlign: TextAlign.center,
          style: appTheme.textTheme.bodyMedium!.copyWith(
            color: LightColors().secondary,
          ),
        ),
      ],
    );
  }
}
