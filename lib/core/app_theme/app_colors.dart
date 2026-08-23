import 'dart:ui';

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

class LightColors implements AppColors {
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
}
