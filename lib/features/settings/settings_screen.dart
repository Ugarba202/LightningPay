import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Text(
          'Settings coming soon',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
