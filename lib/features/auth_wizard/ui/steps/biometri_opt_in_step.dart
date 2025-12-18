import 'package:flutter/material.dart';

class BiometricOptInStep extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const BiometricOptInStep({
    super.key,
    required this.onEnable,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable biometric login',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Use your fingerprint or face to unlock LightningPay faster.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),

          Center(
            child: Icon(Icons.fingerprint, size: 80, color: Colors.orange),
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: onEnable,
            child: const Text('Enable biometrics'),
          ),

          TextButton(onPressed: onSkip, child: const Text('Maybe later')),
        ],
      ),
    );
  }
}
