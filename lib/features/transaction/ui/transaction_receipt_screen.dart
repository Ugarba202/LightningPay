import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import 'package:flutter/services.dart';
import '../model/transation_item.dart';

class TransactionReceiptScreen extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction ID',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    transaction.txId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 20),
                  _Row(label: 'To', value: transaction.address),
                  const SizedBox(height: 8),
                  _Row(label: 'Amount', value: '${transaction.amount} BTC'),
                  const SizedBox(height: 8),
                  _Row(label: 'Network Fee', value: transaction.fee),
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Status',
                    value: transaction.status.toString().split('.').last,
                  ),
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Date',
                    value: transaction.date.toLocal().toString(),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await Clipboard.setData(
                          ClipboardData(text: transaction.txId),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaction ID copied to clipboard'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to copy')),
                        );
                      }
                    },
                    child: const Text('Copy TX ID'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
