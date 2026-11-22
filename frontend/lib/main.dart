// Feito por Luis Felipe Pontes Mita - 25018740

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'routes.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

// true: utiliza os emuladores locais.
// false: utiliza os serviços Firebase publicados.
const bool useFirebaseEmulators = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (useFirebaseEmulators) {
    FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).useFunctionsEmulator('localhost', 5001);

    await FirebaseAuth.instance.useAuthEmulator(
      'localhost',
      9099,
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
