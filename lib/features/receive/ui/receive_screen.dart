import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/widgets/glass_card.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  static const String _btcAddress = 'bc1qexampleaddress1234567890xyz';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Bitcoin'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Glassmorphic QR Container
            _QrContainer(address: _btcAddress),

            const SizedBox(height: 48),

            // Address Label
            Text(
              'Your Bitcoin Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textMed,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Address Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: SelectableText(
                _btcAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy Address',
                    onTap: () {
                      // Mock copy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address copied to clipboard')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share QR',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Security Note
            GlassCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.03),
              child: Row(
                children: [
                   const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       'Only send Bitcoin (BTC) to this address. Sending any other currency may result in permanent loss.',
                       style: TextStyle(color: AppColors.textMed, fontSize: 13, height: 1.4),
                     ),
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

class _QrContainer extends StatelessWidget {
  final String address;

  const _QrContainer({required this.address});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.qr_code_2_rounded, size: 180, color: Colors.black),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textHigh,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

