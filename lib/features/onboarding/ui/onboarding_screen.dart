import 'package:flutter/material.dart';
import 'package:lighting_pay/features/auth_wizard/ui/auth_wizard_screen.dart';

import '../../../core/themes/app_colors.dart';

import '../model/onboarding_item.dart';
import 'onboarding_pade.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const items = [
    OnboardingItem(
      title: 'Bitcoin Wallet',
      description: 'Manage your Bitcoin securely and easily.',
    ),
    OnboardingItem(
      title: 'Lightning Payments',
      description: 'Send and receive payments instantly.',
    ),
    OnboardingItem(
      title: 'Fast & Simple',
      description: 'Built for speed, simplicity, and trust.',
    ),
  ];

  void _next() {
    if (_index < items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthWizardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => OnboardingPage(item: items[i]),
              ),
            ),

            // Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _next,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _index == items.length - 1 ? 'Get Started' : 'Next',
                      key: ValueKey(_index),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
