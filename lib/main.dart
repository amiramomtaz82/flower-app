import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';

import 'config/di/di.dart';
import 'config/locale/locale_service.dart';
import 'config/notificaions/fcm.dart';
import 'core/app_theme/app_theme.dart';
import 'core/ui_action/ui_action.dart';
import 'core/ui_action/ui_action_dispatcher.dart';
import 'core/ui_action/ui_action_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:easy_localization/easy_localization.dart';

import 'config/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configureDependencies();

  final fcm = getIt<Fcm>();
  await fcm.initialize();

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale(AppStrings.en), Locale(AppStrings.ar)],
      path: AppAssets.assetsTranslations,
      fallbackLocale: Locale(AppStrings.en),
      startLocale: Locale(AppStrings.en),
      child: MyApp(
        localeService: getIt<LocaleService>(),
        uiActionDispatcher: getIt<UiActionDispatcher>(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.localeService,
    required this.uiActionDispatcher,
  });

  final LocaleService localeService;
  final UiActionDispatcher uiActionDispatcher;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final UiActionHandler _uiActionHandler;
  StreamSubscription<UiAction>? _uiActionSubscription;

  @override
  void initState() {
    super.initState();
    _uiActionHandler = UiActionHandler(messengerKey: _messengerKey);
    _uiActionSubscription = widget.uiActionDispatcher.stream.listen(
      _uiActionHandler.handle,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.localeService.setLanguageCode(context.locale.languageCode);
  }

  @override
  void dispose() {
    _uiActionSubscription?.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
