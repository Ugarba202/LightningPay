import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import '../../auth_wizard/ui/widget/pin_layout.dart';
import '../../../core/storage/auth_storage.dart';
import '../../auth_wizard/ui/auth_wizard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _step = 0; // 0: email, 1: pin
  String _email = '';
  String _error = '';

  String _pin = '';
  String? _savedEmail;
  String? _savedPin;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    _savedEmail = await AuthStorage.getSavedEmail();
    _savedPin = await AuthStorage.getSavedPin();
    setState(() {
      _loading = false;
    });
  }

  void _submitEmail() {
    final entered = _email.trim();
    if (entered.isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }

    if (_savedEmail == null) {
      // No account exists
      setState(() => _error = 'No account found. Please create one.');
      return;
    }

    if (entered.toLowerCase() != _savedEmail!.toLowerCase()) {
      setState(() => _error = 'No account found for that email');
      return;
    }

    // OK, proceed to PIN step
    setState(() {
      _error = '';
      _step = 1;
    });
  }

  void _onKeyPressed(String value) async {
    if (_pin.length < 6) {
      setState(() => _pin += value);
      if (_pin.length == 6) {
        // Check PIN
        if (_savedPin != null && _pin == _savedPin) {
          // success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        } else {
          // incorrect PIN
          setState(() {
            _error = 'Incorrect PIN';
            _pin = '';
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
        }
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: _step == 0 ? _buildEmailStep(textTheme) : _buildPinStep(),
      ),
    );
  }

  Widget _buildEmailStep(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back', style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Enter your email to continue', style: textTheme.bodyMedium),
          const SizedBox(height: 32),
          TextField(
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              errorText: _error.isEmpty ? null : _error,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (v) {
              setState(() {
                _email = v;
                if (_error.isNotEmpty) _error = '';
              });
            },
            onSubmitted: (_) => _submitEmail(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitEmail,
                  child: const Text('Next'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // go to registration
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthWizardScreen()),
              );
            },
            child: const Text('Need an account? Create one'),
          ),
        ],
      ),
    );
  }

  Widget _buildPinStep() {
    return Column(
      children: [
        Expanded(
          child: PinLayout(
            title: 'Enter login PIN',
            subtitle: 'Enter your 6-digit PIN to unlock the app',
            pinLength: _pin.length,
            onKeyPressed: _onKeyPressed,
            onDelete: _onDelete,
            dotColor: Colors.orange, pin: '',
          ),
        ),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_error, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                // allow user to reset (for dev) — clear saved credentials and go to register
                await AuthStorage.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthWizardScreen()),
                );
              },
              child: const Text('Forgot PIN / Reset'),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
