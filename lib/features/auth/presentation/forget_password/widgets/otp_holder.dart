import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

/// Pass [errorText] to turn the boxes red and show the message under them,
/// pass `null` to go back to the normal state.
class OtpHolder extends StatelessWidget {
  const OtpHolder({
    super.key,
    this.controller,
    this.focusNode,
    this.length = 4,
    this.errorText,
    this.onCompleted,
    this.onChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int length;

  /// `null` -> normal state, otherwise the boxes are painted with the error
  /// color and this text is shown under them.
  final String? errorText;

  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 64,
      height: 64,
      textStyle: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Pinput(
      length: length,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      mainAxisAlignment: MainAxisAlignment.center,
      separatorBuilder: (_) => const SizedBox(width: 12),
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      submittedPinTheme: defaultPinTheme,
      errorPinTheme: defaultPinTheme.copyDecorationWith(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: colors.error, width: 1.5),
      ),
      forceErrorState: errorText != null,
      errorText: errorText,
      errorBuilder: (errorText, pin) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.error_outline, size: 16, color: colors.error),
            const SizedBox(width: 4),
            Text(
              errorText ?? '',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
        ),
      ),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
