import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

extension ThemeColors on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? LightColors();
}