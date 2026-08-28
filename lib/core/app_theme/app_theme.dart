import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = _buildTheme(
      LightColors(), Brightness.light);


  static ThemeData _buildTheme(LightColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.white,
        secondary: colors.secondary,
        onSecondary: colors.white,
        error: colors.error,
        onError: colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// ----------------------- Text theme----------------------///
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
       titleMedium: TextStyle(
          fontSize: 18,
          color: colors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: colors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: colors.textPrimary,
        ),
      ),

      ///--------------- text Field -------------------///
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,

        // Background of the field and floating label area
        filled: true,
        fillColor: colors.background,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.darkGrey,
        ),

        // Label when the field has an error
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
              (states) {
            if (states.contains(WidgetState.error)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.error,
              );
            }

            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.darkGrey,
            );
          },
        ),

        hintStyle: TextStyle(
          fontSize: 14,
          color: colors.hint,
        ),

        errorStyle: TextStyle(
          fontSize: 12,
          color: colors.error,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colors.border,
            width: 1.2,
          ),
          gapPadding: 5,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colors.border,
            width: 1.2,
          ),
          gapPadding: 5,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colors.border,
            width: 1.5,
          ),
          gapPadding: 5,
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colors.error,
            width: 1.2,
          ),
          gapPadding: 5,
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: colors.error,
            width: 1.5,
          ),
          gapPadding: 5,
        ),
      ),
      //------------------Snack Bar-------------------
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(
          color: colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actionTextColor: colors.white,
      ),



      ///---------------- Elevated button ------------------------////

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.darkGrey,
          disabledForegroundColor: colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      //-------------------Navigation Bar---------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.white,
        elevation: 0,
        height: 70,
        indicatorColor: colors.white,

        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colors.primary,
              size: 24,
            );
          }

          return IconThemeData(
            color: colors.darkGrey,
            size: 24,
          );
        }),

        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:colors.primary,
            );
          }

          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.darkGrey,
          );
        }),
      ),


    );
  }
}