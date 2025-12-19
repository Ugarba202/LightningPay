import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../onboarding/ui/onboarding_screen.dart';
import '../../auth/ui/login_screen.dart';
import '../../../core/storage/auth_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => _visible = true);
    });

    Timer(const Duration(seconds: 3), () async {
      final registered = await AuthStorage.isRegistered();
      if (registered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: _visible ? 1 : 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Text(
                  'LightningPay',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                offset: _visible ? Offset.zero : const Offset(0, 0.2),
                child: Text(
                  'Fast Bitcoin Payments',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
