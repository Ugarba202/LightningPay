import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import 'transaction_result_screen.dart';
import '../../transaction/data/transaction_storage.dart';
import '../../transaction/model/transation_item.dart';

class SendConfirmSheet extends StatefulWidget {
  final String? address;
  final String? amount;

  const SendConfirmSheet({super.key, this.address, this.amount});

  @override
  State<SendConfirmSheet> createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  bool _isSending = false;

  Future<Map<String, dynamic>> _simulateSend() async {
    setState(() => _isSending = true);
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final success = Random().nextDouble() < 0.85; // 85% success rate
    final txId = List.generate(
      24,
      (_) => Random().nextInt(16).toRadixString(16),
    ).join();
    setState(() => _isSending = false);

    return {'success': success, 'txId': txId};
  }

  void _onSendNow() async {
    final result = await _simulateSend();

    // Close the bottom sheet first
    if (mounted) Navigator.of(context).pop();

    // Save transaction to local history
    final success = result['success'] as bool;
    final txId = result['txId'] as String;

    final double amountVal = double.tryParse(widget.amount ?? '') ?? 0.0;

    await TransactionStorage.addTransaction(
      TransactionItem(
        title: success ? 'Sent' : 'Failed send',
        date: DateTime.now(),
        amount: amountVal,
        type: success ? TransactionType.sent : TransactionType.sent,
        status: success
            ? TransactionStatus.completed
            : TransactionStatus.failed,
        txId: txId,
        address: widget.address ?? 'Unknown',
        fee: '0.0001 BTC',
      ),
    );

    // Then navigate to the result screen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            success: success,
            address: widget.address ?? 'Unknown',
            amount: widget.amount ?? '—',
            fee: '0.0001 BTC',
            txId: txId,
            message: success ? null : 'Network error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isSending
          ? SizedBox(
              height: 160,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Sending transaction...'),
                ],
              ),
            )
          : Column(
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

                if (widget.address != null) ...[
                  _Row(label: 'To', value: widget.address!),
                  const SizedBox(height: 8),
                ],

                _Row(label: 'Amount', value: widget.amount ?? '—'),
                _Row(label: 'Fee', value: '0.0001 BTC'),
                // If amount is numeric show total, else show placeholder
                _Row(
                  label: 'Total',
                  value: widget.amount != null ? widget.amount! : '—',
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _onSendNow,
                  child: const Text('Send Now'),
                ),

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
