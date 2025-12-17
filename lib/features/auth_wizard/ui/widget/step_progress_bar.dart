import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
