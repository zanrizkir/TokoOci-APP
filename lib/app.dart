import 'package:flutter/material.dart';

import 'config/routes/app_routes.dart';
import 'config/routes/route_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/services/navigation_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: grey,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: grey,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[900]),
          titleTextStyle: darkTextStyle.copyWith(
            fontSize: 16,
            fontWeight: bold,
          ),
        ),
        useMaterial3: true,
      ),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
