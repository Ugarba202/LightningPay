import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/service/transaction_service.dart';
import '../../../core/themes/app_colors.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txService = TransactionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: txService.transactionsStream(), // ✅ FIXED HERE
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ❌ Error
          if (snapshot.hasError) {
            debugPrint('Transaction Stream Error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load transactions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHigh,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This usually happens if a Firestore index is missing. Check your console for a setup link.\n\nError: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMed),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(color: AppColors.textMed),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final type = data['type'] ?? '';
              final amountBtc = (data['amountBtc'] ?? 0).toDouble();
              final amountLocal = (data['amountLocal'] ?? 0).toDouble();
              final currency = data['currency'] ?? '';
              final createdAt = data['createdAt'] as Timestamp?;
              final note = data['note'];

              String title = 'Transaction';
              IconData icon = Icons.help_outline_rounded;
              Color iconColor = AppColors.textMed;
              String amountStr = '';
              bool isPositive = false;

              switch (type) {
                case 'send':
                  title = 'Sent BTC';
                  icon = Icons.call_made_rounded;
                  iconColor = AppColors.error;
                  amountStr = '-${amountBtc.toStringAsFixed(6)} BTC';
                  isPositive = false;
                  break;
                case 'receive':
                  title = 'Received BTC';
                  icon = Icons.call_received_rounded;
                  iconColor = AppColors.success;
                  amountStr = '+${amountBtc.toStringAsFixed(6)} BTC';
                  isPositive = true;
                  break;
                case 'convert':
                  title = 'Converted BTC';
                  icon = Icons.swap_horiz_rounded;
                  iconColor = AppColors.primary;
                  amountStr = '${amountBtc.toStringAsFixed(6)} BTC';
                  isPositive = false;
                  break;
                case 'deposit':
                  title = 'Deposited Funds';
                  icon = Icons.add_circle_outline_rounded;
                  iconColor = AppColors.success;
                  amountStr = '+$amountLocal $currency';
                  isPositive = true;
                  break;
                case 'withdraw':
                  title = 'Withdrew Funds';
                  icon = Icons.remove_circle_outline_rounded;
                  iconColor = AppColors.error;
                  amountStr = '-$amountLocal $currency';
                  isPositive = false;
                  break;
              }

              return _TransactionTile(
                title: title,
                subtitle: note ?? 'Bitcoin transaction',
                amount: amountStr,
                isPositive: isPositive,
                icon: icon,
                iconColor: iconColor,
                date: createdAt?.toDate(),
              );
            },
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final DateTime? date;

  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textHigh,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMed,
                    fontSize: 13,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${date!.day}/${date!.month}/${date!.year}',
                    style: const TextStyle(
                      color: AppColors.textLow,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color:
                  isPositive ? AppColors.success : AppColors.textHigh,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
