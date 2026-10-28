import 'package:flutter/material.dart';

import 'pages/auth/login_page.dart';
import 'pages/auth/password_recovery_pages.dart';
import 'pages/auth/register_page.dart';
import 'pages/auth/splash_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        resetPassword: (_) => const ResetPasswordPage(),
      };
}

/// Caminho da imagem do logo (declarado em pubspec.yaml).
const String kLogoAsset = 'assets/images/logo.png';
