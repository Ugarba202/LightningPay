import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WithdrawService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> withdrawLocal({
    required double amount,
    String? note,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final userRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      if (!snap.exists) throw Exception('User not found');

      final wallet = snap['wallet'];
      final currentBalance = (wallet['localBalance'] ?? 0).toDouble();

      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      final newBalance = currentBalance - amount;

      tx.update(userRef, {
        'wallet.localBalance': newBalance,
      });

      final txRef = userRef.collection('transactions').doc();
      final globalTxRef = _firestore.collection('transactions').doc();

      final txData = {
        'type': 'withdraw',
        'senderId': user.uid,
        'receiverId': 'external',
        'amountLocal': amount,
        'amountBtc': null,
        'currency': wallet['currency'],
        'note': note ?? 'Withdrawal',
        'createdAt': FieldValue.serverTimestamp(),
      };

      tx.set(txRef, txData);
      tx.set(globalTxRef, txData);
    });
  }
}
