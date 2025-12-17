import 'package:flutter/material.dart';

import '../../../core/constant/contry_code.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import 'steps/pin_comfirm_step.dart' show PinConfirmStep;
import 'widget/step_progress_bar.dart';

// Steps
import 'steps/name_step.dart';
import 'steps/country_step.dart';

import 'steps/email_step.dart';
import 'steps/pin_create_step.dart';




class AuthWizardScreen extends StatefulWidget {
  const AuthWizardScreen({super.key});

  @override
  State<AuthWizardScreen> createState() => _AuthWizardScreenState();
}

class _AuthWizardScreenState extends State<AuthWizardScreen> {
  // Controls page switching
  final PageController _pageController = PageController();

  // Step counter (for progress bar)
  int _currentStep = 1;

  // Total number of steps in the wizard
  static const int _totalSteps = 9;

  // =========================
  // TEMPORARY USER DATA (UI ONLY)
  // =========================
  String? name;
  Country? country;
  String? phone;
  String? email;

  String? loginPin;
  String? transactionPin;

  // =========================
  // MOVE TO NEXT STEP
  // =========================
  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // STEP PROGRESS BAR
            // =========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 1)
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

            // =========================
            // STEPS CONTENT
            // =========================
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 1️⃣ NAME
                  NameStep(
                    onCompleted: (name) {
                      this.name = name;
                      _nextStep();
                    },
                  ),

                  // 2️⃣ COUNTRY
                  CountryStep(
                    onCompleted: (country) {
                      this.country = country;
                      _nextStep();
                    },
                  ),

                  // 3️⃣ PHONE
                  // PhoneStep(
                  //   country: country ?,
                  //   onCompleted: (phone) {
                  //     this.phone = phone;
                  //     _nextStep();
                  //   },
                  // ),

                  // 4️⃣ EMAIL
                  EmailStep(
                    onCompleted: (email) {
                      this.email = email;
                      _nextStep();
                    },
                  ),

                  // 5️⃣ CREATE LOGIN PIN
                  PinCreateStep(
                    onCompleted: (pin) {
                      this.loginPin = pin;
                      _nextStep();
                    },
                  ),

                  // 6️⃣ CONFIRM LOGIN PIN
                  PinConfirmStep(
                    originalPin: loginPin ?? '',
                    onCompleted: _nextStep,
                  ),

                 

                  // 9️⃣ SEED PHRASE (FINAL STEP)
                  PinConfirmStep(
                    onCompleted: () {
                      // User finished onboarding
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigationScreen(),
                        ),
                      );
                    }, originalPin: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
