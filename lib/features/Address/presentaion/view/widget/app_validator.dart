import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/app_constants/app_strings.dart';


class AppValidators {
  AppValidators._();

  static String? validateLabel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterLabel.tr();
    }
    return null;
  }

  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterRecipientName.tr();
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterPhoneNumber.tr();
    }
    final cleanVal = value.trim();
    // Egyptian phone pattern: 11 digits starting with 010, 011, 012, or 015
    final phoneRegex = RegExp(r'^(010|011|012|015)[0-9]{8}$');
    if (!phoneRegex.hasMatch(cleanVal)) {
      return AppStrings.pleaseEnterPhoneNumber.tr();
    }
    return null;
  }

  static String? validateAddressDetails(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.pleaseEnterAddressDetails.tr();
    }
    return null;
  }

  static String? validateRequiredField(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? validateSelection<T>(T? value, String errorMessage) {
    if (value == null) {
      return errorMessage;
    }
    return null;
  }
}