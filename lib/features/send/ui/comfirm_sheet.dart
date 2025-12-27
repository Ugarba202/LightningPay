import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/widgets/glass_card.dart';
import 'transaction_result_screen.dart';
import '../../transaction/data/transaction_storage.dart';
import '../../transaction/model/transation_item.dart';
import '../../../core/themes/widgets/transaction_pin_sheet.dart';

class SendConfirmSheet extends StatefulWidget {
  final String? address;
  final String? username;
  final String? amount;

  const SendConfirmSheet({
    super.key,
    this.address,
    this.username,
    this.amount,
  });

  @override
  State<SendConfirmSheet> createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  bool _isSending = false;

  Future<Map<String, dynamic>> _simulateSend() async {
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2));
    final success = Random().nextDouble() < 0.95; // High success rate for demo
    final txId = List.generate(24, (_) => Random().nextInt(16).toRadixString(16)).join();
    setState(() => _isSending = false);
    return {'success': success, 'txId': txId};
  }

  void _onSendNow() {
    TransactionPinSheet.show(
      context,
      onVerified: _executeSend,
    );
  }

  void _executeSend() async {
    final result = await _simulateSend();
    if (!mounted) return;
    Navigator.of(context).pop();

    final success = result['success'] as bool;
    final txId = result['txId'] as String;
    final double amountVal = double.tryParse(widget.amount ?? '') ?? 0.0;

    await TransactionStorage.addTransaction(
      TransactionItem(
        title: success
            ? (widget.username != null && widget.username!.isNotEmpty
                ? 'Sent to ${widget.username}'
                : 'Sent')
            : 'Failed send',
        date: DateTime.now(),
        amount: amountVal,
        currency: 'BTC',
        type: TransactionType.sent,
        status: success ? TransactionStatus.completed : TransactionStatus.failed,
        txId: txId,
        address: widget.address ?? 'Unknown',
        username: widget.username,
        fee: '0.0001 BTC',
      ),
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            success: success,
            address: widget.address ?? 'Unknown',
            username: widget.username,
            amount: widget.amount ?? '0.00',
            fee: '0.0001 BTC',
            txId: txId,
            message: success ? null : 'Transaction verification failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDark.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: _isSending
          ? SizedBox(
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Broadcasting Transaction...',
                    style: TextStyle(
                      color: AppColors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Securing your payment on the Bitcoin network',
                    style: TextStyle(color: AppColors.textMed, fontSize: 13),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textLow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Review Payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${widget.amount} BTC',
                    style: const TextStyle(
                      color: AppColors.textHigh,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white.withOpacity(0.03),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Recipient',
                        value: widget.username ??
                            (widget.address != null
                                ? (widget.address!.length > 12
                                    ? '${widget.address!.substring(0, 10)}...'
                                    : widget.address!)
                                : '—'),
                        isPrimary: true,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(label: 'Network Fee', value: '0.0001 BTC'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _onSendNow,
                  child: const Text('Confirm and Send'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel Payment',
                    style: TextStyle(color: AppColors.textLow, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _DetailRow({required this.label, required this.value, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textMed, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: isPrimary ? AppColors.primary : AppColors.textHigh,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

