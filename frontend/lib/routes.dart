import 'package:flutter/material.dart';

import 'pages/auth/login_page.dart';
import 'pages/auth/password_recovery_pages.dart';
import 'pages/auth/register_page.dart';
import 'pages/auth/splash_page.dart';
import 'pages/content/detailed_view_page.dart';
import 'pages/content/wishlist_page.dart';
import 'pages/home/main_page.dart';
import 'pages/settings/settings_page.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const detailedView = '/detailed-view';
  static const wishlist = '/wishlist';
  static const settings = '/settings';
  

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        home: (_) => const MainPage(),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        resetPassword: (_) => const ResetPasswordPage(),
        detailedView: (_) => const DetailedViewPage(),
        wishlist: (_) => const WishlistPage(),
        settings: (_) => const SettingsPage(),
      };
}

/// Caminho da imagem do logo (declarado em pubspec.yaml).
const String kLogoAsset = 'assets/images/logo.png';
