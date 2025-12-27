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
  final String? username;
  final String? reason;
  final String? note;

  TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    required this.txId,
    required this.address,
    required this.fee,
    this.username,
    this.reason,
    this.note,
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
      username: json['username'] as String?,
      reason: json['reason'] as String?,
      note: json['note'] as String?,
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
    'username': username,
    'reason': reason,
    'note': note,
  };
}
