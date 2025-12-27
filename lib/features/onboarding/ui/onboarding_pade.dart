import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/widgets/glass_card.dart';
import '../model/onboarding_item.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final IconData icon;

  const OnboardingPage({
    super.key,
    required this.item,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 32,
            child: Icon(
              icon,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 60),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textMed,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
