enum TransactionType {
  sent,
  received,
  lightning,
}

enum TransactionStatus {
  completed,
  pending,
}

class TransactionItem {
  final String title;
  final String date;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;

  const TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
  });
}
