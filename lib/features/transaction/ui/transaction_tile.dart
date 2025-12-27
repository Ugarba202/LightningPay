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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _Icon(type: transaction.type),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      dateText,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMed),
                    ),
                    if (transaction.reason != null && transaction.reason!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: AppColors.textLow)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          transaction.reason!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMed),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isReceived ? '+' : '-'}${transaction.amount.toStringAsFixed(6)} BTC',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isReceived ? AppColors.success : AppColors.textHigh,
                ),
              ),
              const SizedBox(height: 6),
              _StatusBadge(status: transaction.status),
            ],
          ),
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
    Color color;

    switch (type) {
      case TransactionType.received:
        icon = Icons.south_west_rounded;
        color = AppColors.success;
        break;
      case TransactionType.sent:
        icon = Icons.north_east_rounded;
        color = AppColors.primary;
        break;
      case TransactionType.lightning:
        icon = Icons.bolt_rounded;
        color = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 22),
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
        color = AppColors.warning;
        break;
      case TransactionStatus.failed:
        text = 'Failed';
        color = AppColors.error;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

