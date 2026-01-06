import 'package:cloud_firestore/cloud_firestore.dart';

class WalletBalanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔒 Atomic BTC transfer between two users
  Future<void> transferBtc({
    required String senderUserId,
    required String receiverUserId,
    required double amountBtc,
  }) async {
    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    final senderRef = _firestore.collection('users').doc(senderUserId);
    final receiverRef = _firestore.collection('users').doc(receiverUserId);

    await _firestore.runTransaction((transaction) async {
      final senderSnap = await transaction.get(senderRef);
      final receiverSnap = await transaction.get(receiverRef);

      if (!senderSnap.exists || !receiverSnap.exists) {
        throw Exception('User not found');
      }

      final senderWallet = Map<String, dynamic>.from(senderSnap['wallet']);
      final receiverWallet = Map<String, dynamic>.from(receiverSnap['wallet']);

      final double senderBalance = (senderWallet['btcBalance'] ?? 0).toDouble();

      if (senderBalance < amountBtc) {
        throw Exception('Insufficient BTC balance');
      }

      // 🔻 Deduct sender
      senderWallet['btcBalance'] = senderBalance - amountBtc;

      // 🔺 Credit receiver
      final double receiverBalance = (receiverWallet['btcBalance'] ?? 0)
          .toDouble();
      receiverWallet['btcBalance'] = receiverBalance + amountBtc;

      transaction.update(senderRef, {'wallet': senderWallet});
      transaction.update(receiverRef, {'wallet': receiverWallet});
    });
  }

  /// 🟢 Increase BTC balance (receive, deposit, convert)
  Future<void> creditBtc({
    required String userId,
    required double amountBtc,
  }) async {
    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(userRef);
      if (!snap.exists) throw Exception('User not found');

      final wallet = Map<String, dynamic>.from(snap['wallet']);
      final current = (wallet['btcBalance'] ?? 0).toDouble();

      wallet['btcBalance'] = current + amountBtc;

      transaction.update(userRef, {'wallet': wallet});
    });
  }

  /// 🔴 Decrease BTC balance (withdraw, convert)
  Future<void> debitBtc({
    required String userId,
    required double amountBtc,
  }) async {
    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(userRef);
      if (!snap.exists) throw Exception('User not found');

      final wallet = Map<String, dynamic>.from(snap['wallet']);
      final current = (wallet['btcBalance'] ?? 0).toDouble();

      if (current < amountBtc) {
        throw Exception('Insufficient BTC balance');
      }

      wallet['btcBalance'] = current - amountBtc;

      transaction.update(userRef, {'wallet': wallet});
    });
  }
}
