import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'rate_service.dart';
import 'transaction_service.dart';

class ConvertService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _rateService = RateService();
  final _txService = TransactionService();

  /// Convert BTC → Local currency
  Future<void> convertBtcToLocal({
    required double btcAmount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final userRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception('User not found');

      final data = snapshot.data()!;
      final wallet = Map<String, dynamic>.from(data['wallet'] ?? {});

      if (wallet.isEmpty) throw Exception('Wallet not initialized');

      final currentBtc = (wallet['btcBalance'] ?? 0.0).toDouble();
      final currentLocal = (wallet['localBalance'] ?? 0.0).toDouble();
      final currency = wallet['currency'] as String? ?? 'USD';

      if (btcAmount <= 0) {
        throw Exception('Invalid amount');
      }

      if (currentBtc < btcAmount) {
        throw Exception('Insufficient BTC balance');
      }

      final localAmount = _rateService.btcToLocal(
        btcAmount: btcAmount,
        currency: currency,
      );

      // 🔄 Update wallet atomically
      wallet['btcBalance'] = currentBtc - btcAmount;
      wallet['localBalance'] = currentLocal + localAmount;

      transaction.update(userRef, {'wallet': wallet});

      // 🧾 Record transaction ATOMICALLY
      await _txService.createTransaction(
        senderId: user.uid,
        receiverId: user.uid,
        amountBtc: btcAmount,
        localAmount: localAmount,
        type: 'convert',
        note: 'Converted BTC to $currency',
        firestoreTransaction: transaction,
      );
    });
  }
}