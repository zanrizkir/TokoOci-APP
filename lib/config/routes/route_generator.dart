import 'package:flutter/material.dart';
import 'package:tokooci_app/features/auth/login_screen.dart';
import 'package:tokooci_app/features/auth/register_screen.dart';
import 'package:tokooci_app/features/auth/profile_screen.dart';
import 'package:tokooci_app/features/cart/cart_screen.dart';
import 'package:tokooci_app/features/intro/intro_screen.dart';
import 'package:tokooci_app/features/home/presentation/home_screen.dart';
import 'package:tokooci_app/features/splash/splash_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.intro:
        return MaterialPageRoute(builder: (_) => IntroScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Route Error')),
        body: const Center(child: Text('Halaman tidak ditemukan')),
      ),
    );
  }
}