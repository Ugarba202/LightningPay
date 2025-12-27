import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import '../../../core/themes/widgets/glass_card.dart';
import '../../transaction/model/transation_item.dart';
import '../../transaction/ui/transaction_receipt_screen.dart';

class TransactionResultScreen extends StatelessWidget {
  final bool success;
  final String address;
  final String amount;
  final String fee;
  final String txId;
  final String? username;
  final String? message;

  const TransactionResultScreen({
    super.key,
    required this.success,
    required this.address,
    required this.amount,
    required this.fee,
    required this.txId,
    this.username,
    this.message,
  });

  String get _shortTxId {
    if (txId.length <= 12) return txId;
    return '${txId.substring(0, 8)}...${txId.substring(txId.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Animated Success/Failure State
              _ResultHeader(success: success),

              const SizedBox(height: 40),

              Text(
                success ? 'Payment Successful' : 'Payment Failed',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textHigh,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                success
                    ? 'Your transaction has been broadcasted to the network.'
                    : (message ?? 'There was a problem processing your payment.'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMed, fontSize: 15, height: 1.5),
              ),

              const SizedBox(height: 48),

              // Glassmorphic Details Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                color: Colors.white.withOpacity(0.03),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Recipient', 
                      value: username ?? (address.length > 15 ? '${address.substring(0, 10)}...' : address),
                      isPrimary: success,
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Amount Paid', value: '$amount BTC'),
                    const SizedBox(height: 16),
                    _DetailRow(label: 'Transaction ID', value: _shortTxId),
                  ],
                ),
              ),

              const Spacer(),

              if (success) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Return to Home'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    final tx = TransactionItem(
                      title: 'Sent',
                      date: DateTime.now(),
                      amount: double.tryParse(amount) ?? 0.0,
                      type: TransactionType.sent,
                      status: TransactionStatus.completed,
                      txId: txId,
                      address: address,
                      fee: fee,
                      username: username,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TransactionReceiptScreen(transaction: tx)),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: const Text('View Digital Receipt'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withOpacity(0.8)),
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  child: Text('Close', style: TextStyle(color: AppColors.textLow, fontWeight: FontWeight.bold)),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final bool success;

  const _ResultHeader({required this.success});

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.error;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Inner Circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Icon(
              success ? Icons.check_rounded : Icons.close_rounded,
              size: 56,
              color: color,
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

