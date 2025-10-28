import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../utils/constants.dart';
import '../services/hive_service.dart';
import '../utils/themes.dart';
import '../services/theme_service.dart';
import '../routes/routes.dart';
import 'firebase_options.dart';
import '../services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  FirestoreService.configure();
  await HiveService.initialize();
  tz.initializeTimeZones();
  runApp(ProcessPathApp());
}

class ProcessPathApp extends StatelessWidget {
  const ProcessPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    final robotoText = robotoTextTheme(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          key: const ValueKey('App'), // 👈 add this
          title: AppConstants.appName,
          theme: lightTheme.copyWith(textTheme: robotoText),
          darkTheme: darkTheme.copyWith(textTheme: robotoText),
          themeMode: mode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
