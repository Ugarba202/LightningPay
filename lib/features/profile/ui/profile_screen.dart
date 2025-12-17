import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../model/user_profile.dart';
import 'profile_text_field.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Mock profile (UI-only)
  static const UserProfile _user = UserProfile(
    name: 'Usman Garba',
    email: 'usman@example.com',
    imageUrl: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Editable fields
             ProfileTextField(
              label: 'Full Name',
              initialValue: _user.name,
            ),
            const SizedBox(height: 16),

            ProfileTextField(
              label: 'Email',
              initialValue: _user.email,
            ),

            const SizedBox(height: 16),

            const ProfileTextField(
              label: 'Phone (optional)',
              initialValue: '',
            ),
          ],
        ),
      ),
    );
  }
}
