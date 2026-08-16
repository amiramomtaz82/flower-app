import 'package:firebase_core/firebase_core.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter/material.dart';

import 'config/di/di.dart';
import 'config/notificaions/fcm.dart';
import 'core/app_theme/app_theme.dart';

import 'package:easy_localization/easy_localization.dart';

import 'core/go_routes/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();




  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  configureDependencies();


  final fcm = getIt<Fcm>();


  await fcm.initialize();


  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: AppAssets.assetsTranslations,
      fallbackLocale:  Locale(AppStrings.en),
      startLocale:  Locale(AppStrings.en),
      child: const MyApp(),
    ),
  );


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
