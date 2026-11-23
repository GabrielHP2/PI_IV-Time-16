
// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configuração dos emuladores Firebase
  const bool useFirebaseEmulators = true;

  if (useFirebaseEmulators) {
    await FirebaseAuth.instance.useAuthEmulator(
      '127.0.0.1',
      9099,
    );

    FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).useFunctionsEmulator(
      '127.0.0.1',
      5001,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamhub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
