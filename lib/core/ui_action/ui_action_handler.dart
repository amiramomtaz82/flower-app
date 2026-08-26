import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../app_constants/app_strings.dart';
import '../../config/router/app_router.dart';
import 'ui_action.dart';

class UiActionHandler {
  UiActionHandler({required this.messengerKey});

  final GlobalKey<ScaffoldMessengerState> messengerKey;

  void handle(UiAction action) {
    switch (action) {
      case NavigateAction(:final routeName, :final replace):
        _navigate(routeName, replace: replace);
      case ShowSnackBarAction(:final type, :final message):
        _showSnackBar(type, message);
      case DialogAction(:final title, :final message):
        _showDialog(title, message);
    }
  }

  void _navigate(String routeName, {required bool replace}) {
    if (replace) {
      AppRouter.router.go(routeName);
    } else {
      AppRouter.router.push(routeName);
    }
  }

  void _showSnackBar(SnackBarType type, String message) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    final context = AppRouter.navigatorKey.currentContext;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message.tr()),
          backgroundColor: type == SnackBarType.error && context != null
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      );
  }

  void _showDialog(String title, String message) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title.tr()),
        content: Text(message.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.confirm.tr()),
          ),
        ],
      ),
    );
  }
}
