// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF804F99);
  static const logoCircle = Color(0xFF4F1D6B);
  static const fieldFill = Color(0xFFF5E6FF);
  static const fieldBorder = Color(0xFF4A2060);
  static const button = Color(0xFF2A0A3C);
  static const onDark = Colors.white;
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.background,
          primary: AppColors.button,
          surface: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.onDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
