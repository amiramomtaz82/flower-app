import 'package:flutter/material.dart';

abstract class AppColors {
  Color get primary;

  Color get secondary;

  Color get error;

  Color get success;

  Color get black;

  Color get white;

  Color get grey;

  Color get darkGrey;

  Color get background;

  Color get surface;

  Color get textPrimary;

  Color get textSecondary;

  Color get border;

  Color get divider;

  Color get hint;
}

/// Registered as a [ThemeExtension] in [AppTheme] so widgets read colors via
/// `Theme.of(context).extension<LightColors>()` instead of instantiating
/// this directly — `ThemeExtension<T>` requires `T` to itself be the
/// extension type, so this can't be keyed by the abstract [AppColors]
/// interface, but the theme is still the single place a color scheme is
/// constructed.
class LightColors extends ThemeExtension<LightColors> implements AppColors {
  @override
  Color get background => const Color(0xffF2F2F7);

  @override
  Color get black => const Color(0xff0C1015);

  @override
  Color get border => const Color(0xff1D1B20);

  @override
  Color get darkGrey => const Color(0xff535353);

  @override
  Color get divider => const Color(0xffF9F9F9);

  @override
  Color get error => const Color(0xffCC1010);

  @override
  Color get grey => const Color(0xffA6A6A6);

  @override
  Color get hint => const Color(0xffA6A6A6);

  @override
  Color get primary => const Color(0xffD21E6A);

  @override
  Color get secondary => const Color(0xff535353);

  @override
  Color get success => const Color(0xff0CB359);

  @override
  Color get surface => const Color(0xffCFCFCF);

  @override
  Color get textPrimary => const Color(0xff0C1015);

  @override
  Color get textSecondary => const Color(0xffF2F2F7);

  @override
  Color get white => const Color(0xffF2F2F7);

  @override
  LightColors copyWith() => LightColors();

  @override
  LightColors lerp(covariant ThemeExtension<LightColors>? other, double t) =>
      this;
}
