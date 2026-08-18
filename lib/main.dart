import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/di/di.dart';
import 'core/app_theme/app_theme.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:go_router/go_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  
  final goRouter = getIt<GoRouter>();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MyApp(goRouter: goRouter),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter goRouter;
  
  const MyApp({super.key, required this.goRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
