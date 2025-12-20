import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

import '../model/transation_item.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isReceived = transaction.type == TransactionType.received;

    final dateText = () {
      final now = DateTime.now();
      final dt = transaction.date.toLocal();
      final diff = now.difference(dt).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return dt.toLocal().toString().split(' ').first;
    }();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Icon(type: transaction.type),
      title: Text(transaction.title),
      subtitle: Text(dateText),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${isReceived ? '+' : '-'}${transaction.amount.toStringAsFixed(6)} BTC',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isReceived ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          _StatusBadge(status: transaction.status),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final TransactionType type;

  const _Icon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (type) {
      case TransactionType.received:
        icon = Icons.arrow_downward;
        break;
      case TransactionType.sent:
        icon = Icons.arrow_upward;
        break;
      case TransactionType.lightning:
        icon = Icons.flash_on;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    switch (status) {
      case TransactionStatus.completed:
        text = 'Completed';
        color = AppColors.success;
        break;
      case TransactionStatus.pending:
        text = 'Pending';
        color = Colors.orange;
        break;
      case TransactionStatus.failed:
        text = 'Failed';
        color = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
