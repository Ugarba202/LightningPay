enum TransactionType { sent, received, lightning }

enum TransactionStatus { completed, pending, failed }

class TransactionItem {
  final String title;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String txId;
  final String address;
  final String fee;

  TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    required this.txId,
    required this.address,
    required this.fee,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      txId: json['txId'] as String? ?? '',
      address: json['address'] as String? ?? '',
      fee: json['fee'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
    'amount': amount,
    'type': type.toString(),
    'status': status.toString(),
    'txId': txId,
    'address': address,
    'fee': fee,
  };
}
