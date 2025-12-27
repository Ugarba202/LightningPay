import 'package:flutter/material.dart';
import '../../../core/constant/contry_code.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/themes/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _recoveryController = TextEditingController();

  Country _selectedCountry = supportedCountries.first;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final name = await AuthStorage.getFullName();
    final email = await AuthStorage.getSavedEmail();
    final username = await AuthStorage.getUsername();
    final phone = await AuthStorage.getPhoneNumber();
    final countryStr = await AuthStorage.getCountry();
    final recovery = await AuthStorage.getRecoveryPhrase();

    if (countryStr != null) {
      // try to match by name
      final match = supportedCountries.firstWhere(
        (c) => '${c.flag} ${c.name}' == countryStr,
        orElse: () => supportedCountries.first,
      );
      _selectedCountry = match;
    }

    setState(() {
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
      _usernameController.text = username ?? '';
      _phoneController.text = phone ?? '';
      _recoveryController.text = recovery ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await AuthStorage.saveFullName(_nameController.text.trim());
    await AuthStorage.saveUsername(_usernameController.text.trim());
    await AuthStorage.savePhoneNumber(_phoneController.text.trim());
    await AuthStorage.saveCountry(
      '${_selectedCountry.flag} ${_selectedCountry.name}',
    );
    await AuthStorage.saveRecoveryPhrase(_recoveryController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _recoveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InputFieldLabel(label: 'Full Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppColors.textHigh),
                      validator: (v) => v == null || v.trim().length < 2 ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 20),

                    _InputFieldLabel(label: 'Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textHigh),
                      decoration: const InputDecoration(hintText: 'Enter your email'),
                      validator: (v) => v != null && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 20),

                    _InputFieldLabel(label: 'Username'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: AppColors.textHigh),
                      decoration: const InputDecoration(
                        prefixText: '@ ',
                        prefixStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _InputFieldLabel(label: 'Country'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Country>(
                      value: _selectedCountry,
                      dropdownColor: AppColors.surfaceDark,
                      style: const TextStyle(color: AppColors.textHigh),
                      items: supportedCountries.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.flag} ${c.name}'),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCountry = v);
                      },
                    ),
                    const SizedBox(height: 20),

                    _InputFieldLabel(label: 'Phone Number'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_selectedCountry.flag} ${_selectedCountry.dialCode}',
                            style: const TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: AppColors.textHigh),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _InputFieldLabel(label: 'Recovery Phrase'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recoveryController,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textHigh, fontFamily: 'monospace', fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Enter your 12 or 24 word recovery phrase...',
                      ),
                    ),

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Changes'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InputFieldLabel extends StatelessWidget {
  final String label;
  const _InputFieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMed,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
