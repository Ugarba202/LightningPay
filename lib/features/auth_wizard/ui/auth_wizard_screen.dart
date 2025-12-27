import 'package:flutter/material.dart';

import '../../../core/constant/contry_code.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import 'widget/step_progress_bar.dart';

import '../../../core/storage/auth_storage.dart';
// Steps
import 'steps/name_step.dart';
import 'steps/username_step.dart';
import 'steps/country_step.dart';
import 'steps/email_step.dart';
import 'steps/otp_step.dart';
import 'steps/phone_step.dart';
import 'steps/pin_create_step.dart';
import 'steps/pin_comfirm_step.dart';

class AuthWizardScreen extends StatefulWidget {
  const AuthWizardScreen({super.key});

  @override
  State<AuthWizardScreen> createState() => _AuthWizardScreenState();
}

class _AuthWizardScreenState extends State<AuthWizardScreen> {
  // Controls page switching
  final PageController _pageController = PageController();

  // Step counter (for progress bar)
  int _currentStep = 0;

  int _totalSteps = 0;

  String? name;
  String? username;
  String? email;
  Country? country;
  String? phone;
  String? loginPin;

  // State for UI
  bool _isStepValid = false;
  // Initialize to empty to avoid any late initialization issues during navigation
  List<Widget> _wizardSteps = [];

  // Notifier to tell steps when we want to show validation errors
  final ValueNotifier<bool> _showValidationNotifier = ValueNotifier(false);

  // When the user successfully confirms the PIN we show a progress
  // indicator for a short period before navigating to the dashboard.
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _wizardSteps = _getWizardSteps();
    _totalSteps = _wizardSteps.length;
    _currentStep = 0; // Start at step 1
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showValidationNotifier.dispose();
    super.dispose();
  }

  List<Widget> _getWizardSteps() => [
    NameStep(
      showValidationNotifier: _showValidationNotifier,
      onCompleted: (value) => _updateValidation(value, (val) => name = val),
    ),

    // Email -> OTP flow (OTP accepts any 6-digit code in dev mode)
    EmailStep(
      showValidationNotifier: _showValidationNotifier,
      onCompleted: (value) => _updateValidation(value, (val) => email = val),
    ),

    OtpStep(
      onCompleted: (value) {
        // mark the step as valid (no persistent value needed)
        _updateValidation(value, (val) {});
        // clear any validation UI and advance to the next step
        _showValidationNotifier.value = false;
        _nextStep();
      },
    ),

    // Select country next
    CountryStep(
      showValidationNotifier: _showValidationNotifier,
      onCompleted: (value) {
        setState(() {
          country = value;
          // ignore: unnecessary_null_comparison
          _isStepValid = value != null;
        });
      },
    ),

    // Phone number step (shows country dial code when available)
    PhoneStep(
      country: country ?? supportedCountries.first,
      onCompleted: (value) => _updateValidation(value, (val) => phone = val),
    ),

    // Username after country & phone
    UsernameStep(
      showValidationNotifier: _showValidationNotifier,
      onValidationChanged: (value) =>
          _updateValidation(value, (val) => username = val),
    ),

    // PIN create & confirm
    PinCreateStep(onCompleted: _onPinCreated),
    PinConfirmStep(
      originalPin: loginPin ?? '',
      onCompleted: _onPinConfirmed,
      dotColor: Colors.red,
    ),
  ];

  void _updateValidation(String value, Function(String?) onValid) {
    setState(() {
      final isValid = value.isNotEmpty;
      if (isValid) {
        onValid(value);
      } else {
        onValid(null);
      }
      _isStepValid = isValid;
    });
  }

  // =========================
  // MOVE TO NEXT STEP
  // =========================
  void _nextStep() {
    if (_currentStep >= _totalSteps - 1) return;

    if (_currentStep < _totalSteps && _isStepValid) {
      // If we're moving *from* the Email step (index 1) to OTP (index 2),
      // refresh the OTP step instance so it can show the most recent email.
      if (_currentStep == 1) {
        final otpIndex = 2;
        if (otpIndex >= 0 && otpIndex < _wizardSteps.length) {
          _wizardSteps[otpIndex] = OtpStep(
            email: email,
            onCompleted: (value) {
              // mark the step as valid (no persistent value needed)
              _updateValidation(value, (val) {});
              // clear any validation UI and advance to the next step
              _showValidationNotifier.value = false;
              _nextStep();
            },
          );
        }
      }

      // If we're moving from Country -> Phone, refresh the PhoneStep so it
      // shows the newly selected country dial code.
      if (_currentStep == 3) {
        final phoneIndex = 4;
        if (phoneIndex >= 0 && phoneIndex < _wizardSteps.length) {
          _wizardSteps[phoneIndex] = PhoneStep(
            country: country ?? supportedCountries.first,
            onCompleted: (value) =>
                _updateValidation(value, (val) => phone = val),
          );
        }
      }

      setState(() {
        _isStepValid = false; // Reset for the next step
        _currentStep++;
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _attemptNextStep() {
    // Show errors in child steps
    _showValidationNotifier.value = true;

    // If the current step is valid, clear validation visuals and move on
    if (_isStepValid) {
      _showValidationNotifier.value = false;
      _nextStep();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _isStepValid = true; // Assume previous steps are always valid
      });
      // Reset validation display when going back
      _showValidationNotifier.value = false;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _onPinCreated(String pin) {
    // Safely replace confirm step with the created pin and navigate to it.
    loginPin = pin;

    final confirmIndex = (_totalSteps - 1).clamp(0, _wizardSteps.length - 1);

    // Protect against inconsistent state where the list might be smaller
    if (confirmIndex >= 0 && confirmIndex < _wizardSteps.length) {
      setState(() {
        _wizardSteps[confirmIndex] = PinConfirmStep(
          originalPin: loginPin!,
          onCompleted: _onPinConfirmed,
          dotColor: Colors.orange,
        );
        _currentStep = confirmIndex;
      });

      // Animate explicitly to the confirm page (safer than nextPage)
      _pageController.animateToPage(
        confirmIndex,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _onPinConfirmed() async {
    // Show confirmation progress for a short time, save credentials, then navigate
    setState(() => _isConfirming = true);

    // Save the newly created credentials locally so returning users can log in
    if (email != null && loginPin != null) {
      await AuthStorage.saveCredentials(email!, loginPin!);
    }

    // Also save profile fields collected during the wizard
    if (name != null && name!.isNotEmpty) {
      await AuthStorage.saveFullName(name!);
    }
    if (username != null && username!.isNotEmpty) {
      await AuthStorage.saveUsername(username!);
    }
    if (country != null) {
      await AuthStorage.saveCountry('${country!.flag} ${country!.name}');
    }
    if (phone != null && phone!.isNotEmpty) {
      await AuthStorage.savePhoneNumber(phone!);
    }

    // Generate and store a recovery phrase for now (dev/mock)
    final phraseWords = [
      'light',
      'river',
      'coffee',
      'tree',
      'wallet',
      'secure',
      'orange',
      'planet',
      'trust',
      'future',
      'energy',
      'freedom',
    ];
    await AuthStorage.saveRecoveryPhrase(phraseWords.join(' '));

    Future.delayed(const Duration(seconds: 5), () async {
      if (!mounted) return;
      // Mark that we should prompt the user to set up a transaction PIN on first run
      await AuthStorage.markNeedTransactionSetup(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            _wizardSteps.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 24, 24, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _previousStep,
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

                      if (_currentStep <= _totalSteps - 2) // Hide on PIN steps
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

            // Overlay progress when confirming PIN
            if (_isConfirming)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
