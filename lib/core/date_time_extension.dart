import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension DateTimeFormatExtension on DateTime? {
  /// Formats date to: "03 Sep 2024, 11:00 AM"
  String toDeliveryFormat(BuildContext context, {String fallback = ''}) {
    if (this == null) return fallback;
    return DateFormat('dd MMM yyyy, hh:mm a', context.locale.toString())
        .format(this!.toLocal());
  }
}

extension StringDateFormatExtension on String? {
  /// Parses raw ISO string and formats to: "03 Sep 2024, 11:00 AM"
  String toDeliveryFormat(BuildContext context, {String fallback = ''}) {
    if (this == null || this!.trim().isEmpty) return fallback;
    final parsed = DateTime.tryParse(this!)?.toLocal();
    if (parsed == null) return this!;
    return DateFormat('dd MMM yyyy, hh:mm a', context.locale.toString())
        .format(parsed);
  }
}