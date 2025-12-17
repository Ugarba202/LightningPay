import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Divider(),
        const SizedBox(height: 16),

        _SocialButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onPressed: () {},
        ),
        const SizedBox(height: 12),

        _SocialButton(
          label: 'Continue with Apple',
          icon: Icons.apple,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.textPrimary),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.border),
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('OR'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
