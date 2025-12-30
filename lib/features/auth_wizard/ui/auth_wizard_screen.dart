import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constant/contry_code.dart';

import '../../../core/service/user_service.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import '../../../core/storage/auth_storage.dart';

// Steps
import 'steps/name_step.dart';
import 'steps/email_step.dart';
import 'steps/verify_email_step.dart';
import 'steps/country_step.dart';
import 'steps/phone_step.dart';
import 'steps/username_step.dart';
import 'steps/pin_create_step.dart';
import 'steps/pin_comfirm_step.dart';

import 'widget/step_progress_bar.dart';

class AuthWizardScreen extends StatefulWidget {
  const AuthWizardScreen({super.key});

  @override
  State<AuthWizardScreen> createState() => _AuthWizardScreenState();
}

class _AuthWizardScreenState extends State<AuthWizardScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  late final int _totalSteps;

  String? name;
  String? email;
  String? phone;
  String? username;
  String? loginPin;
  Country? country;

  bool _isStepValid = false;
  bool _isConfirming = false;
  bool _isSendingVerification = false;

  final ValueNotifier<bool> _showValidationNotifier = ValueNotifier(false);

  late final List<Widget> _wizardSteps;

  @override
  void initState() {
    super.initState();
    _wizardSteps = _buildSteps();
    _totalSteps = _wizardSteps.length;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showValidationNotifier.dispose();
    super.dispose();
  }

  List<Widget> _buildSteps() => [
    NameStep(
      showValidationNotifier: _showValidationNotifier,
      onCompleted: (value) => _updateValidation(value, (val) => name = val),
    ),

    EmailStep(
      showValidationNotifier: _showValidationNotifier,
      onCompleted: (value) => _updateValidation(value, (val) => email = val),
    ),

    VerifyEmailStep(onVerified: _nextStep),

    CountryStep(
      showValidationNotifier: _showValidationNotifier,
      onCompleted: (value) {
        country = value;
        setState(() => _isStepValid = value != null);
      },
    ),

    PhoneStep(
      country: supportedCountries.first,
      onCompleted: (value) => _updateValidation(value, (val) => phone = val),
    ),

    UsernameStep(
      showValidationNotifier: _showValidationNotifier,
      onValidationChanged: (value) =>
          _updateValidation(value, (val) => username = val),
    ),

    PinCreateStep(onCompleted: _onPinCreated),
    const SizedBox(),
  ];

  void _updateValidation(String value, Function(String?) onValid) {
    setState(() {
      final isValid = value.trim().isNotEmpty;
      onValid(isValid ? value : null);
      _isStepValid = isValid;
    });
  }

  Future<void> _createUserAndSendVerification() async {
    if (email == null || email!.isEmpty) {
      throw Exception('Email is required');
    }

    setState(() => _isSendingVerification = true);

    final auth = FirebaseAuth.instance;

    try {
      const tempPassword = 'Temp@123456';

      await auth.createUserWithEmailAndPassword(
        email: email!,
        password: tempPassword,
      );

      await auth.currentUser!.sendEmailVerification();

      await Future.delayed(const Duration(milliseconds: 5500));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account with this email already exists.');
      }
      throw Exception(e.message ?? 'Authentication error');
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  void _attemptNextStep() async {
    _showValidationNotifier.value = true;

    if (!_isStepValid) return;

    _showValidationNotifier.value = false;

    if (_currentStep == 1) {
      try {
        await _createUserAndSendVerification();
        _nextStep();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    _nextStep();
  }

  void _nextStep() {
    if (_currentStep >= _totalSteps - 1) return;

    setState(() {
      _isStepValid = false;
      _currentStep++;
    });

    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPinCreated(String pin) {
    loginPin = pin;

    final confirmIndex = _totalSteps - 1;

    _wizardSteps[confirmIndex] = PinConfirmStep(
      originalPin: loginPin!,
      onCompleted: _onPinConfirmed,
      dotColor: Colors.orange,
    );

    setState(() => _currentStep = confirmIndex);

    _pageController.animateToPage(
      confirmIndex,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  // here is to store use infor
  Future<void> _onPinConfirmed() async {
    setState(() => _isConfirming = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      // 1️⃣ Update password (TEMP → PIN)
      await user.updatePassword(loginPin!);

      // 2️⃣ Create Firestore profile
      final userService = UserService();
      await userService.createUserProfile(
        fullName: name!,
        username: username!,
        email: email!,
        phone: phone!,
        country: '${country!.flag} ${country!.name}',
      );

      // 3️⃣ Save locally
      await AuthStorage.saveCredentials(email!, loginPin!);
      await AuthStorage.saveFullName(name!);
      await AuthStorage.saveUsername(username!);
      await AuthStorage.saveCountry('${country!.flag} ${country!.name}');
      await AuthStorage.savePhoneNumber(phone!);

      await AuthStorage.markNeedTransactionSetup(true);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConfirming = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Setup error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 24, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      Expanded(
                        child: StepProgressBar(
                          currentStep: _currentStep,
                          totalSteps: _totalSteps,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _wizardSteps,
                  ),
                ),
                if (_currentStep < _totalSteps - 2)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _attemptNextStep,
                        child: const Text('Next'),
                      ),
                    ),
                  ),
              ],
            ),

            if (_isSendingVerification)
              _overlayLoader('Sending verification email...'),

            if (_isConfirming) _overlayLoader('Creating your account...'),
          ],
        ),
      ),
    );
  }

  Widget _overlayLoader(String text) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(text),
          ],
        ),
      ),
    );
  }
}
