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

  Color get hint;





}
class LightColors implements AppColors {
  @override
  get background => const Color(0xffF2F2F7
  );

  @override
  get black => const Color(0xff0C1015);

  @override
  get border => const Color(0xff1D1B20);

  @override
  get darkGrey => const Color(0xff535353);

  @override
  get error => const Color(0xffCC1010);

  @override
  get grey => const Color(0xffA6A6A6);

  @override
  get hint => const Color(0xffA6A6A6);

  @override
  get primary => const Color(0xffD21E6A);

  @override
  get secondary => const Color(0xff535353);

  @override
  get success => const Color(0xff0CB359);

  @override
  get surface => const Color(0xffCFCFCF);

  @override
  get textPrimary => const Color(0xff0C1015);

  @override
  get textSecondary => const Color(0xffF2F2F7);

  @override
  get white => const Color(0xffF2F2F7);
}