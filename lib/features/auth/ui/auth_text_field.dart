import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final bool obscureText;

  const AuthTextField({
    super.key,
    required this.label,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
        ),
      ),
    );
  }
}
