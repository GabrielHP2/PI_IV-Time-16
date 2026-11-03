import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
<<<<<<< HEAD
import 'pages/content/home_screen.dart';
=======
>>>>>>> parent of ac72e5a (main_page, wishlist e tema)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEMO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,

    );
  }
}
