import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  send,
  receive,
  convert,
  deposit,
  withdraw,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
}

class AppTransaction {
  final String id;
  final TransactionType type;
  final String senderId;
  final String? receiverId;
  final double btcAmount;
  final double localAmount;
  final String currency;
  final TransactionStatus status;
  final String? note;
  final DateTime createdAt;

  AppTransaction({
    required this.id,
    required this.type,
    required this.senderId,
    this.receiverId,
    required this.btcAmount,
    required this.localAmount,
    required this.currency,
    required this.status,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'senderId': senderId,
      'receiverId': receiverId,
      'btcAmount': btcAmount,
      'localAmount': localAmount,
      'currency': currency,
      'status': status.name,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppTransaction.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return AppTransaction(
      id: doc.id,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
      ),
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      btcAmount: (data['btcAmount'] ?? 0).toDouble(),
      localAmount: (data['localAmount'] ?? 0).toDouble(),
      currency: data['currency'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == data['status'],
      ),
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
