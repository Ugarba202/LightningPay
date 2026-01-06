import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepositService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> depositLocal({
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

      final newBalance = currentBalance + amount;

      tx.update(userRef, {
        'wallet.localBalance': newBalance,
      });

      final txRef = userRef.collection('transactions').doc();
      tx.set(txRef, {
        'type': 'deposit',
        'amountLocal': amount,
        'amountBtc': null,
        'note': note ?? 'Deposit',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
