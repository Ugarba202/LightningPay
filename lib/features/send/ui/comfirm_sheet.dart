import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class SendConfirmSheet extends StatelessWidget {
  final String? address;
  final String? amount;

  const SendConfirmSheet({super.key, this.address, this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Confirm Transaction',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          if (address != null) ...[
            _Row(label: 'To', value: address!),
            const SizedBox(height: 8),
          ],

          _Row(label: 'Amount', value: amount ?? '—'),
          _Row(label: 'Fee', value: '0.0001 BTC'),
          // If amount is numeric show total, else show placeholder
          _Row(label: 'Total', value: amount != null ? amount! : '—'),

          const SizedBox(height: 24),

          ElevatedButton(onPressed: () {}, child: const Text('Send Now')),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
