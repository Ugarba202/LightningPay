import 'package:flutter/material.dart';

import '../../../core/storage/auth_storage.dart';
import '../../auth_wizard/ui/widget/pin_layout.dart';
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
      // Use a light translucent overlay so the background isn't black
      backgroundColor: Colors.white.withOpacity(0.92),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _isSaving
              ? _buildSaving()
              : _step == 0
              ? _buildChoice()
              : _step == 1
              ? _buildCreate()
              : _buildConfirm(),
        ),
      ),
    );
  }

  Widget _buildChoice() {
    final mq = MediaQuery.of(context).size;
    final maxH = mq.height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 360, maxHeight: maxH),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: maxH),
          child: Center(
            child: Container(
              key: const ValueKey('choice'),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Secure your transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Choose how you want to secure your transactions'),
                  const SizedBox(height: 12),

                  // Toggle between enabling fingerprint and creating a PIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Use fingerprint to approve transactions'),
                      ),
                      Switch(
                        value: _useBiometricsSelected,
                        onChanged: (v) =>
                            setState(() => _useBiometricsSelected = v),
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _useBiometricsSelected
                              ? _enableBiometrics
                              : () => setState(() => _step = 1),
                          child: Text(
                            _useBiometricsSelected
                                ? 'Enable fingerprint'
                                : 'Create transaction PIN',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Skip for now
                      Navigator.of(context).pop();
                    },
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreate() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SingleChildScrollView(
        child: Container(
          key: const ValueKey('create'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Create 4-digit PIN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('This PIN will be required to approve transactions'),
              const SizedBox(height: 20),

              // Inline create UI (includes dots and keypad)
              _InlinePinCreate(
                onCompleted: (pin) => _onCreatePinCompleted(pin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SingleChildScrollView(
        child: Container(
          key: const ValueKey('confirm'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Confirm PIN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Re-enter your 4-digit PIN'),
              const SizedBox(height: 20),

              // Inline confirm UI (includes dots and keypad)
              _InlinePinCreate(
                pinLength: 4,
                onCompleted: (pin) => _onConfirmPinCompleted(pin),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaving() {
    final mq = MediaQuery.of(context).size;
    final maxH = mq.height * 0.5;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 320, maxHeight: maxH),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: maxH),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Creating PIN...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small inline PIN create widget that uses the same keypad logic as the
/// registration PIN creation but tailored for 4-digit transaction PINs.
class _InlinePinCreate extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final int pinLength;

  _InlinePinCreate({Key? key, required this.onCompleted, this.pinLength = 4})
    : super(key: key);

  @override
  State<_InlinePinCreate> createState() => _InlinePinCreateState();
}

class _InlinePinCreateState extends State<_InlinePinCreate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
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
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.scale(scale: _scale.value, child: child);
          },
          child: SizedBox(
            height: 96,
            child: PinLayout(
              title: '',
              subtitle: '',
              pinLength: 0,
              onKeyPressed: (value) {},
              onDelete: () {},
              dotColor: Colors.orange,
              dotCount: widget.pinLength,
              showKeyboard: false,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Use boxes for numeric input instead of on-screen keypad
        Center(
          child: OtpBoxes(
            length: widget.pinLength,
            onCompleted: _onBoxesCompleted,
            activeColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}
