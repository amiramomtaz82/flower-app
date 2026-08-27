
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';


import '../../features/auth/data/data_source/local/auth_local_data_source.dart';
import '../../config/router/app_router.dart';
import '../go_routes/routes_name.dart';
import 'auth_required_bottom_sheet.dart';



  @lazySingleton
 class GuestBrowsingProvider {
  final AuthLocalDataSource _authLocalDataSource;

  Future<void> Function()? _pendingAction;
  GuestBrowsingProvider(this._authLocalDataSource);

  bool get hasPendingAction => _pendingAction != null;

  Future<bool> hasSession() async {
    final token =  await _authLocalDataSource.getToken();


    return token != null && token.isNotEmpty;
  }
  Future<void> requireAuth({
    required Future<void> Function() action,
  }) async {
    final authenticated = await hasSession();

    if (authenticated) {
      await action();
      return;
    }

    _pendingAction = action;

    final context = AppRouter.navigatorKey.currentContext;

    if (context == null) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return AuthRequiredBottomSheet(
          onLogin: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.login);
          },
          onRegister: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.register);
          },
        );
      },
    );
  }


  Future<void> executePendingAction() async {
    final action = _pendingAction;

    _pendingAction = null;

    if (action != null) {
      await action();
    }
  }
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
  }