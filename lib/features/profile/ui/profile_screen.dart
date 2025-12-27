import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lighting_pay/features/auth/ui/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/themes/widgets/glass_card.dart';

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
  String? recoveryPhrase;

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
                    _confirmRemoveProfileImage();
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

  Future<void> _confirmRemoveProfileImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Photo'),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _removeProfileImage();
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
    final imagePath = await AuthStorage.getProfileImagePath();

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
      recoveryPhrase = recovery;
      _profileImagePath = imagePath;
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

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // For now, just navigate to login. In a real app you'd clear tokens.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Avatar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.bgDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                alignment: Alignment.center,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.bgDark,
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar Container
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.surfaceDark,
                              backgroundImage: _profileImagePath != null
                                  ? FileImage(File(_profileImagePath!))
                                  : null,
                              child: _profileImagePath == null
                                  ? const Icon(Icons.person_rounded, size: 54, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceActionSheet,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _fullName ?? 'Premium User',
                        style: const TextStyle(
                          color: AppColors.textHigh,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailAddr ?? 'user@lightningpay.com',
                        style: TextStyle(color: AppColors.textMed, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account Information
                  _SectionHeader(title: 'Account Information'),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white.withOpacity(0.02),
                    child: Column(
                      children: [
                        _ProfileItem(
                          icon: Icons.phone_rounded,
                          label: 'Phone',
                          value: _phone ?? 'Not set',
                        ),
                        _Divider(),
                        _ProfileItem(
                          icon: Icons.public_rounded,
                          label: 'Country',
                          value: _country ?? 'Not set',
                        ),
                        _Divider(),
                        _ProfileItem(
                          icon: Icons.alternate_email_rounded,
                          label: 'Username',
                          value: _username != null ? '@$_username' : 'Not set',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Security
                  _SectionHeader(title: 'Security & Privacy'),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white.withOpacity(0.02),
                    child: Column(
                      children: [
                        _ProfileItem(
                          icon: Icons.fingerprint_rounded,
                          label: 'Biometrics',
                          value: _biometricsEnabled ? 'Enabled' : 'Disabled',
                          onTap: _toggleBiometrics,
                          showTrailing: true,
                        ),
                        _Divider(),
                        _ProfileItem(
                          icon: Icons.shield_rounded,
                          label: 'Transaction PIN',
                          value: _hasTransactionPin ? 'Active' : 'Not set',
                          onTap: _editTransactionPin,
                          showTrailing: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Actions List
                  _ProfileActionTile(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile Settings',
                    onTap: () async {
                      final updated = await Navigator.of(context).push<bool?>(
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                      if (updated == true) await _loadSecurityState();
                    },
                  ),
                  const SizedBox(height: 12),
                  _ProfileActionTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Support & FAQ',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ProfileActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: AppColors.error.withOpacity(0.8),
                    onTap: _confirmLogout,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Center(
                    child: Text(
                      'LightningPay v1.2.0',
                      style: TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textLow,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppColors.border.withOpacity(0.3), height: 1),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showTrailing;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.showTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: AppColors.textMed, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textHigh,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (showTrailing)
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textLow),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textHigh;
    
    return GlassCard(
      padding: EdgeInsets.zero,
      color: Colors.white.withOpacity(0.02),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: effectiveColor),
        title: Text(
          label,
          style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textLow),
      ),
    );
  }
}
