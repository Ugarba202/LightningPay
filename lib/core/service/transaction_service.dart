import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final _db = FirebaseFirestore.instance;

  Future<void> sendBtc({
    required String receiverUserId,
    required double amountBtc,
  }) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;

    final senderRef = _db.collection('users').doc(senderId);
    final receiverRef = _db.collection('users').doc(receiverUserId);
    final txRef = _db.collection('transactions').doc();

    await _db.runTransaction((transaction) async {
      final senderSnap = await transaction.get(senderRef);
      final receiverSnap = await transaction.get(receiverRef);

      if (!senderSnap.exists || !receiverSnap.exists) {
        throw Exception('User not found');
      }

      final senderBalance =
          (senderSnap.data()!['btcBalance'] as num).toDouble();

      if (senderBalance < amountBtc) {
        throw Exception('Insufficient BTC balance');
      }

      // 1️⃣ Deduct from sender
      transaction.update(senderRef, {
        'btcBalance': senderBalance - amountBtc,
      });

      // 2️⃣ Add to receiver
      final receiverBalance =
          (receiverSnap.data()!['btcBalance'] as num).toDouble();

      transaction.update(receiverRef, {
        'btcBalance': receiverBalance + amountBtc,
      });

      // 3️⃣ Create transaction record
      transaction.set(txRef, {
        'senderId': senderId,
        'receiverId': receiverUserId,
        'amountBtc': amountBtc,
        'type': 'send',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
