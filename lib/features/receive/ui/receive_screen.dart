import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  // Temporary placeholder address (UI-only)
  static const String _btcAddress = 'bc1qexampleaddress1234567890xyz';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Receive Bitcoin')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // QR Code placeholder
            _QrPlaceholder(),

            const SizedBox(height: 32),

            // Address label
            Text(
              'Your Bitcoin Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            // Address container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _btcAddress,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Info note
            Text(
              'Share this address to receive Bitcoin payments.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(Icons.qr_code, size: 140, color: AppColors.primary),
      ),
    );
  }
}
