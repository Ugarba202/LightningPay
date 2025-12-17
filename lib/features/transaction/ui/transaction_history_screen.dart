import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../model/transation_item.dart';
import 'transaction_tile.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const List<TransactionItem> _transactions = [
    TransactionItem(
      title: 'Lightning Payment',
      date: 'Today',
      amount: 0.002,
      type: TransactionType.sent,
      status: TransactionStatus.completed,
    ),
    TransactionItem(
      title: 'Bitcoin Received',
      date: 'Yesterday',
      amount: 0.010,
      type: TransactionType.received,
      status: TransactionStatus.completed,
    ),
    TransactionItem(
      title: 'Lightning Invoice',
      date: '2 days ago',
      amount: 0.001,
      type: TransactionType.lightning,
      status: TransactionStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView.separated(
          itemCount: _transactions.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return TransactionTile(
              transaction: _transactions[index],
            );
          },
        ),
      ),
    );
  }
}
