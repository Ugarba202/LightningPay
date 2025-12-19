import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/storage/auth_storage.dart';
import '../../auth/ui/transaction_pin_flow.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricsEnabled = false;
  bool _hasTransactionPin = false;

  // Profile fields
  String? _fullName;
  String? _emailAddr;
  String? _country;
  String? _phone;
  String? _username;
  String? _recoveryPhrase;

  // Profile image path
  String? _profileImagePath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${extension(picked.path)}';
      final saved = await File(picked.path).copy('${appDir.path}/$fileName');

      await AuthStorage.saveProfileImagePath(saved.path);
      setState(() => _profileImagePath = saved.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      if (_profileImagePath != null) {
        final file = File(_profileImagePath!);
        if (await file.exists()) await file.delete();
      }
      await AuthStorage.removeProfileImagePath();
      setState(() => _profileImagePath = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to remove image')));
    }
  }

  String extension(String path) {
    final idx = path.lastIndexOf('.');
    return idx >= 0 ? path.substring(idx) : '.png';
  }

  @override
  void initState() {
    super.initState();
    _loadSecurityState();
  }

  Future<void> _loadSecurityState() async {
    final bio = await AuthStorage.isBiometricsEnabled();
    final tx = await AuthStorage.getSavedTransactionPin();

    // profile fields
    final name = await AuthStorage.getFullName();
    final email = await AuthStorage.getSavedEmail();
    final country = await AuthStorage.getCountry();
    final phone = await AuthStorage.getPhoneNumber();
    final username = await AuthStorage.getUsername();
    final recovery = await AuthStorage.getRecoveryPhrase();

    setState(() {
      _biometricsEnabled = bio;
      _hasTransactionPin = tx != null && tx.isNotEmpty;
      _fullName = name;
      _emailAddr = email;
      _country = country;
      _phone = phone;
      _username = username;
      _recoveryPhrase = recovery;
    });
  }

  void _toggleBiometrics() async {
    await AuthStorage.setBiometricsEnabled(!_biometricsEnabled);
    await _loadSecurityState();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _biometricsEnabled ? 'Biometrics enabled' : 'Biometrics disabled',
        ),
      ),
    );
  }

  void _editTransactionPin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TransactionPinFlow(forceCreate: true),
      ),
    );
    await _loadSecurityState();
  }

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
            Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))
                      : null,
                  child: _profileImagePath == null
                      ? const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: _showImageSourceActionSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              _fullName ?? 'Your name',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _emailAddr ?? 'Not provided',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            // =====================
            // ACCOUNT INFO
            // =====================
            _ProfileCard(
              title: 'Account Information',
              children: [
                _ProfileItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: _phone ?? 'Not provided',
                ),
                _ProfileItem(
                  icon: Icons.flag,
                  label: 'Country',
                  value: _country ?? 'Not provided',
                ),
                _ProfileItem(
                  icon: Icons.person,
                  label: 'Username',
                  value: _username ?? 'Not provided',
                ),
                _ProfileItem(
                  icon: Icons.phonelink_lock,
                  label: 'Recovery phrase',
                  value: _recoveryPhrase != null && _recoveryPhrase!.isNotEmpty
                      ? 'Saved'
                      : 'Not set',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================
            // SECURITY
            // =====================
            _ProfileCard(
              title: 'Security',
              children: [
                _ProfileItem(
                  icon: Icons.lock,
                  label: 'Login PIN',
                  value: 'Enabled',
                ),
                _ProfileItem(
                  icon: Icons.fingerprint,
                  label: 'Biometrics',
                  value: _biometricsEnabled ? 'Enabled' : 'Disabled',
                ),
                _ProfileItem(
                  icon: Icons.shield,
                  label: 'Transaction PIN',
                  value: _hasTransactionPin ? 'Enabled' : 'Disabled',
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
              onTap: () async {
                final updated = await Navigator.of(context).push<bool?>(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                if (updated == true) {
                  await _loadSecurityState();
                }
              },
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

            const SizedBox(height: 12),

            // Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleBiometrics,
                    child: Text(
                      _biometricsEnabled
                          ? 'Disable fingerprint'
                          : 'Enable fingerprint',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _editTransactionPin,
                    child: Text(
                      _hasTransactionPin
                          ? 'Edit transaction PIN'
                          : 'Create transaction PIN',
                    ),
                  ),
                ),
              ],
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
