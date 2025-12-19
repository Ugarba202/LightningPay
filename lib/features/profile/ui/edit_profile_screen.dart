import 'package:flutter/material.dart';
import '../../../core/constant/contry_code.dart';
import '../../../core/storage/auth_storage.dart';

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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full name',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: (v) => v == null || v.trim().length < 2
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    Text('Email', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
                      // We allow editing email for now
                      validator: (v) =>
                          v != null &&
                              RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Username',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(controller: _usernameController),
                    const SizedBox(height: 12),

                    Text(
                      'Country',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Country>(
                      value: _selectedCountry,
                      items: supportedCountries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.flag} ${c.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCountry = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    Text('Phone', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_selectedCountry.flag} ${_selectedCountry.dialCode}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Recovery phrase',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recoveryController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
