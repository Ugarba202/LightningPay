import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lighting_pay/features/splash/ui/splashscreen.dart';
import 'package:lighting_pay/firebase_options.dart';

import 'core/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LightningPayApp());
}

class LightningPayApp extends StatelessWidget {
  const LightningPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LightningPay',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
