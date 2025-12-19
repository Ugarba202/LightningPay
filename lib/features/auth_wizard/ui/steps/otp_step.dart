import 'dart:async';

import 'package:flutter/material.dart';

import '../widget/otp_boxes.dart';

/// OTP step used during registration to verify the user's email address.
///
/// In this development build there is no backend, so *any* 6-digit code will
/// be accepted and the step will mark itself as completed and advance.
class OtpStep extends StatefulWidget {
  final ValueChanged<String> onCompleted;

  /// Optional email to display on the OTP screen (e.g., "Code sent to x@y.z")
  final String? email;

  const OtpStep({super.key, required this.onCompleted, this.email});

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _remainingSeconds = 0;
  static const int _cooldownSeconds = 30;

  @override
  void initState() {
    super.initState();
    // Simulate sending the initial code when the step appears and start cooldown
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _remainingSeconds = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  void _onResend() {
    // No backend — just provide user feedback and start cooldown
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.email != null
              ? 'Verification code resent to ${widget.email}'
              : 'Verification code resent',
        ),
      ),
    );
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.email != null && widget.email!.isNotEmpty
        ? 'Enter the 6-digit code sent to ${widget.email}'
        : 'Enter the 6-digit code sent to your email';

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify email',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),

                // OTP boxes (no on-screen keypad) — orange styling
                Center(
                  child: OtpBoxes(
                    length: 6,
                    onCompleted: (value) {
                      widget.onCompleted(value);
                    },
                    activeColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Resend button with cooldown / countdown
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TextButton(
            onPressed: _remainingSeconds == 0 ? _onResend : null,
            child: Text(
              _remainingSeconds == 0
                  ? 'Resend code'
                  : 'Resend in ${_remainingSeconds}s',
            ),
          ),
        ),
      ],
    );
  }
}
