import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailStep extends StatefulWidget {
  final VoidCallback onVerified;

  const VerifyEmailStep({super.key, required this.onVerified});

  @override
  State<VerifyEmailStep> createState() => _VerifyEmailStepState();
}

class _VerifyEmailStepState extends State<VerifyEmailStep> {
  bool _isChecking = false;
  bool _isResending = false;
  int _cooldown = 0;
  Timer? _timer;
  String? _error;

  // =========================
  // CHECK EMAIL VERIFICATION
  // =========================
  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });

    // 1️⃣ Reload the user state from Firebase servers
    await FirebaseAuth.instance.currentUser?.reload();

    // 2️⃣ IMPORTANT: Fetch the refreshed user instance
    final refreshedUser = FirebaseAuth.instance.currentUser;

    // 3️⃣ Check the updated verification status
    if (refreshedUser != null && refreshedUser.emailVerified) {
      widget.onVerified();
    } else {
      setState(() {
        _error = 'Email not verified yet. Please check your inbox.';
      });
    }

    setState(() => _isChecking = false);
  }

  // =========================
  // RESEND VERIFICATION EMAIL
  // =========================
  Future<void> _resendVerification() async {
    if (_isResending || _cooldown > 0) return;

    setState(() {
      _isResending = true;
      _cooldown = 30; // 30s cooldown
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification link sent to your email')),
      );
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() {
          _cooldown = 0;
          _isResending = false;
        });
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify your email',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'We’ve sent a verification link to your email address.\n'
            'Please open your email and click the link to continue.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isChecking ? null : _checkVerification,
              child: _isChecking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("I've verified my email"),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: (_cooldown == 0 && !_isResending)
                  ? _resendVerification
                  : null,
              child: Text(
                _cooldown == 0
                    ? 'Resend verification email'
                    : 'Resend in $_cooldown s',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
