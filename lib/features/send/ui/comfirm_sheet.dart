import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/widgets/glass_card.dart';
import '../../../core/themes/widgets/transaction_pin_sheet.dart';
import '../../../core/service/transaction_service.dart';

import 'transaction_result_screen.dart';

class SendConfirmSheet extends StatefulWidget {
  final String? address;
  final String? username;
  final String? amount;

  const SendConfirmSheet({
    super.key,
    this.address,
    this.username,
    this.amount, String? note,
  });

  @override
  State<SendConfirmSheet> createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  bool _isSending = false;

  void _onSendNow() {
    TransactionPinSheet.show(
      context,
      onVerified: _executeSend,
    );
  }

  /// 🔎 Resolve Firestore userId from @username
  Future<String> _resolveReceiverUserId() async {
    if (widget.username == null || widget.username!.isEmpty) {
      throw Exception('Invalid recipient');
    }

    // IMPORTANT FIX: strip @
    final cleanUsername =
        widget.username!.startsWith('@')
            ? widget.username!.substring(1)
            : widget.username!;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: cleanUsername)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Recipient not found');
    }

    return query.docs.first.id;
  }

  Future<void> _executeSend() async {
    setState(() => _isSending = true);

    try {
      // ✅ SAFE amount parsing
      final amountVal = double.tryParse(widget.amount ?? '');
      if (amountVal == null || amountVal <= 0) {
        throw Exception('Invalid amount');
      }

      final receiverUserId = await _resolveReceiverUserId();

      final txService = TransactionService();

      await txService.sendBtc(
        receiverUserId: receiverUserId,
        amountBtc: amountVal,
      );

      if (!mounted) return;

      // Close bottom sheet FIRST
      Navigator.of(context).pop();

      // Then navigate
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            success: true,
            address: widget.address ?? 'Username',
            username: widget.username,
            amount: widget.amount ?? '0.00',
            fee: '0.0001 BTC',
            txId: 'auto-generated',
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('SEND ERROR: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      Navigator.of(context).pop();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            success: false,
            address: widget.address ?? 'Unknown',
            username: widget.username,
            amount: widget.amount ?? '0.00',
            fee: '—',
            txId: '—',
            message: e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
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
                children: const [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Broadcasting Transaction...',
                    style: TextStyle(
                      color: AppColors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Securing your payment',
                    style: TextStyle(
                      color: AppColors.textMed,
                      fontSize: 13,
                    ),
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
                const Text(
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
                        value: widget.username ?? '—',
                        isPrimary: true,
                      ),
                      const SizedBox(height: 16),
                      const _DetailRow(
                        label: 'Network Fee',
                        value: '0.0001 BTC',
                      ),
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
                    style: TextStyle(
                      color: AppColors.textLow,
                      fontWeight: FontWeight.bold,
                    ),
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

  const _DetailRow({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMed,
            fontSize: 13,
          ),
        ),
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
