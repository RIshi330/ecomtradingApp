import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/screens/create_opportunity_screen.dart';
import 'package:trading_ecommerce_admin/services/auth_User_and_Business_Session.dart';
import 'common/opportunity_Details_Screen.dart';
import 'common/opportunity_From2.dart';
import 'common/opportunity_marketplace_Screen.dart';
import 'index.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'SereneCommerceAdmin/1.0 (contact@serenecommerce.com)';
  }
}

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() must be the very first
  // call in main() — every plugin (secure_storage, shared_preferences,
  // HttpOverrides) depends on the binding existing before it's used.
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await SharedPreferences.getInstance();
  await UserSessionSet.instance.init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRoutes.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
          // home: OpportunityMarketplaceScreen(),
    );
  }
}