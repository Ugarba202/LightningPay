import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import 'auth_text_field.dart';
import 'social_auth.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            Text(
              'Create your account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Join LightningPay and send Bitcoin instantly',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // Basic info
            const AuthTextField(label: 'Full Name'),
            const SizedBox(height: 16),

            const AuthTextField(label: 'Email'),
            const SizedBox(height: 16),

            const AuthTextField(label: 'Password', obscureText: true),

            const SizedBox(height: 24),

            // Country selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Country'),
              items: const [
                DropdownMenuItem(value: 'NG', child: Text('Nigeria')),
                DropdownMenuItem(value: 'US', child: Text('United States')),
                DropdownMenuItem(value: 'UK', child: Text('United Kingdom')),
              ],
              onChanged: (value) {},
            ),

            const SizedBox(height: 16),

            // Phone number with country code
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Code'),
                    items: const [
                      DropdownMenuItem(value: '+234', child: Text('+234')),
                      DropdownMenuItem(value: '+1', child: Text('+1')),
                      DropdownMenuItem(value: '+44', child: Text('+44')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sign up button
            ElevatedButton(onPressed: () {}, child: const Text('Sign Up')),

            const SizedBox(height: 32),

            // Social auth
            const SocialAuthButtons(),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
