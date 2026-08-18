import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/di/di.dart';
import 'config/locale/locale_service.dart';
import 'core/app_theme/app_theme.dart';

import 'package:easy_localization/easy_localization.dart';

import 'core/go_routes/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MyApp(localeService: getIt<LocaleService>()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.localeService});

  final LocaleService localeService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs on the first build and again only when EasyLocalization's locale
    // actually changes, since context.locale registers an inherited dependency.
    widget.localeService.setLanguageCode(context.locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
