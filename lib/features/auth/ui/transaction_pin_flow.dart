import 'package:flutter/material.dart';

import '../../../core/storage/auth_storage.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/widgets/glass_card.dart';
import '../../auth_wizard/ui/widget/otp_boxes.dart';

/// Full-screen flow to create a 4-digit transaction PIN or enable biometrics.
///
/// If [forceCreate] is true, it will skip the initial choice screen and show
/// the PIN creation directly (useful for "edit PIN" flows from Profile).
class TransactionPinFlow extends StatefulWidget {
  final bool forceCreate;

  const TransactionPinFlow({super.key, this.forceCreate = false});

  @override
  State<TransactionPinFlow> createState() => _TransactionPinFlowState();
}

class _TransactionPinFlowState extends State<TransactionPinFlow> {
  int _step = 0; // 0: choice, 1: create, 2: confirm, 3: saving

  String _createdPin = '';

  bool _useBiometricsSelected = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.forceCreate) {
      _step = 1;
    }
  }

  void _enableBiometrics() async {
    await AuthStorage.setBiometricsEnabled(true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Biometrics enabled')));
    // If this was the initial setup, clear the "need" flag so we don't re-prompt
    await AuthStorage.markNeedTransactionSetup(false);
    if (mounted) Navigator.of(context).pop();
  }

  void _onCreatePinCompleted(String pin) {
    setState(() {
      _createdPin = pin;
      _step = 2;
    });
  }

  void _onConfirmPinCompleted(String pin) async {
    if (pin != _createdPin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PINs do not match')));
      setState(() {
        _step = 1; // go back to create
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Save and show a short loader similar to registration
    await AuthStorage.saveTransactionPin(pin);
    await Future.delayed(const Duration(seconds: 2));

    // Clear the flag so we don't prompt again
    await AuthStorage.markNeedTransactionSetup(false);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction PIN created successfully')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isSaving
                  ? _buildSaving()
                  : _step == 0
                      ? _buildChoice()
                      : _step == 1
                          ? _buildCreate()
                          : _buildConfirm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        key: const ValueKey('choice'),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Secure Transactions',
              style: TextStyle(
                color: AppColors.textHigh,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose how you want to authorize your payments and security changes.',
              style: TextStyle(color: AppColors.textMed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Toggle Biometrics
            InkWell(
              onTap: () => setState(() => _useBiometricsSelected = !_useBiometricsSelected),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Use Biometrics',
                        style: TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: _useBiometricsSelected,
                      onChanged: (v) => setState(() => _useBiometricsSelected = v),
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _useBiometricsSelected ? _enableBiometrics : () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                _useBiometricsSelected ? 'Enable Biometrics' : 'Continue to PIN',
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Skip for now',
                style: TextStyle(color: AppColors.textLow, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreate() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        key: const ValueKey('create'),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create PIN',
              style: TextStyle(
                color: AppColors.textHigh,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Set a 4-digit PIN for your transactions.',
              style: TextStyle(color: AppColors.textMed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _InlinePinCreate(
              onCompleted: _onCreatePinCompleted,
            ),
            const SizedBox(height: 24),
            if (!widget.forceCreate)
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text('Back', style: TextStyle(color: AppColors.textLow)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        key: const ValueKey('confirm'),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Confirm PIN',
              style: TextStyle(
                color: AppColors.textHigh,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please re-enter your 4-digit PIN.',
              style: TextStyle(color: AppColors.textMed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _InlinePinCreate(
              onCompleted: _onConfirmPinCompleted,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: Text('Reset', style: TextStyle(color: AppColors.textLow)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaving() {
    return GlassCard(
      key: const ValueKey('saving'),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 24),
          Text(
            'Securing Wallet...',
            style: TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Small inline PIN create widget that uses the same keypad logic as the
/// registration PIN creation but tailored for 4-digit transaction PINs.
class _InlinePinCreate extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  _InlinePinCreate({Key? key, required this.onCompleted})
    : super(key: key);

  @override
  State<_InlinePinCreate> createState() => _InlinePinCreateState();
}

class _InlinePinCreateState extends State<_InlinePinCreate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    scale = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onBoxesCompleted(String value) {
    // play completion pulse then return the pin
    _animController.forward().then((_) {
      _animController.reverse().then((_) => widget.onCompleted(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Use boxes for numeric input
        OtpBoxes(
          length: 4,
          onCompleted: _onBoxesCompleted,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
