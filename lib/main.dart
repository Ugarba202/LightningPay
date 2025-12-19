import 'package:flutter/material.dart';
import 'package:lighting_pay/features/splash/ui/splashscreen.dart';

import 'core/themes/app_themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const SplashScreen(),
    );
  }
}
