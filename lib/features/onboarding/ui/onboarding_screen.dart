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
      title: 'Global Payments',
      description: 'Send Bitcoin anywhere in the world instantly, with zero friction.',
    ),
    OnboardingItem(
      title: 'Lightning Speed',
      description: 'Experience the power of the Lightning Network for micro-payments.',
    ),
    OnboardingItem(
      title: 'Total Security',
      description: 'Your funds are secured with industry-leading encryption and standards.',
    ),
  ];

  static const icons = [
    Icons.public_rounded,
    Icons.bolt_rounded,
    Icons.security_rounded,
  ];

  void _next() {
    if (_index < items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthWizardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E2631), AppColors.bgDark],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: TextStyle(color: AppColors.primary.withOpacity(0.8)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: items.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => OnboardingPage(
                      item: items[i],
                      icon: icons[i],
                    ),
                  ),
                ),

                // Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    items.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == i ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _index == items.length - 1 ? 'Get Started' : 'Continue',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
