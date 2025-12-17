import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import 'auth_text_field.dart';
import 'signup_screen.dart';
import 'social_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // Brand / Title
            Hero(
              tag: 'logo',
              child: Text(
                'LightningPay',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Sign in to continue',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 40),

            // Email & Password
            const AuthTextField(label: 'Email'),
            const SizedBox(height: 16),
            const AuthTextField(label: 'Password', obscureText: true),

            const SizedBox(height: 24),

            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainNavigationScreen(),
                  ),
                );
              },
              child: const Text('Login'),
            ),

            // Social Auth
            const SizedBox(height: 32),
            const SocialAuthButtons(),

            // Signup link
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
