import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? LightColors();
}