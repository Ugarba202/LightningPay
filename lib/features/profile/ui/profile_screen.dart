import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // =====================
            // PROFILE HEADER
            // =====================
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            Text('Usman Umar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'usman@example.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // =====================
            // ACCOUNT INFO
            // =====================
            _ProfileCard(
              title: 'Account Information',
              children: const [
                _ProfileItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: '+234 812 345 6789',
                ),
                _ProfileItem(
                  icon: Icons.flag,
                  label: 'Country',
                  value: '🇳🇬 Nigeria',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================
            // SECURITY
            // =====================
            _ProfileCard(
              title: 'Security',
              children: const [
                _ProfileItem(
                  icon: Icons.lock,
                  label: 'Login PIN',
                  value: 'Enabled',
                ),
                _ProfileItem(
                  icon: Icons.fingerprint,
                  label: 'Biometrics',
                  value: 'Enabled',
                ),
                _ProfileItem(
                  icon: Icons.shield,
                  label: 'Recovery Phrase',
                  value: 'Secured',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // =====================
            // ACTIONS
            // =====================
            _ProfileAction(
              icon: Icons.edit,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _ProfileAction(
              icon: Icons.security,
              label: 'Security Settings',
              onTap: () {},
            ),
            _ProfileAction(
              icon: Icons.logout,
              label: 'Log Out',
              color: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
