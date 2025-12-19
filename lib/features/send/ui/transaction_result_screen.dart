import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/navigation/main_navigation_screen.dart';
import '../../transaction/model/transation_item.dart';
import '../../transaction/ui/transaction_receipt_screen.dart';

class TransactionResultScreen extends StatelessWidget {
  final bool success;
  final String address;
  final String amount;
  final String fee;
  final String txId;
  final String? message;

  const TransactionResultScreen({
    super.key,
    required this.success,
    required this.address,
    required this.amount,
    required this.fee,
    required this.txId,
    this.message,
  });

  String get _shortTxId {
    if (txId.length <= 12) return txId;
    return '${txId.substring(0, 6)}...${txId.substring(txId.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Big icon
            Icon(
              success ? Icons.check_circle_outline : Icons.highlight_off,
              size: 110,
              color: success ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 20),

            Text(
              success ? 'Transaction Sent' : 'Transaction Failed',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              success
                  ? 'Your transaction was broadcast successfully.'
                  : (message ?? 'There was an error sending your transaction.'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

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
                  _Row(label: 'To', value: address),
                  const SizedBox(height: 8),
                  _Row(label: 'Amount', value: amount),
                  const SizedBox(height: 8),
                  _Row(label: 'Network Fee', value: fee),
                  const SizedBox(height: 8),
                  _Row(label: 'Transaction ID', value: _shortTxId),
                ],
              ),
            ),

            const Spacer(),

            if (success) ...[
              ElevatedButton(
                onPressed: () {
                  // Go back to main wallet screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Back to Wallet'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Navigate to receipt screen
                  final tx = TransactionItem(
                    title: 'Sent',
                    date: DateTime.now(),
                    amount: double.tryParse(amount) ?? 0.0,
                    type: TransactionType.sent,
                    status: TransactionStatus.completed,
                    txId: txId,
                    address: address,
                    fee: fee,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TransactionReceiptScreen(transaction: tx),
                    ),
                  );
                },
                child: const Text('View receipt'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () {
                  // Retry — pop back to the previous screen (Send flow)
                  Navigator.of(context).pop();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Cancel/Back to wallet
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Back to Wallet'),
              ),
            ],
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
