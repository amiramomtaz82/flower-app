import 'package:flutter/material.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? LightColors();
    
    final errorStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: colors.error,
    );

    final normalStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: colors.darkGrey,
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return errorStyle;
          }
          return normalStyle;
        }),
      ),
    );
  }
}
