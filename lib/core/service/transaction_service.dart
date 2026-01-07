import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'wallet_ledger_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WalletLedgerService _ledger = WalletLedgerService();

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _txRef =>
      _firestore.collection('transactions');

  // ============================================================
  // 🔴 SEND BTC (P2P)
  // ============================================================
  Future<void> sendBtc({
    required String receiverUserId,
    required double amountBtc,
    String? note,
  }) async {
    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    // 1️⃣ Ensure sender has enough BTC
    await _ledger.ensureSufficientBalance(requiredBtc: amountBtc);

    // 2️⃣ Deduct BTC from sender
    await _ledger.updateBalances(btcDelta: -amountBtc);

    // 3️⃣ Credit BTC to receiver
    await _firestore.runTransaction((tx) async {
      final receiverRef = _firestore.collection('users').doc(receiverUserId);
      final snap = await tx.get(receiverRef);

      if (!snap.exists) throw Exception('Receiver wallet not found');

      final data = snap.data()!;
      final wallet = Map<String, dynamic>.from(data['wallet']);

      wallet['btcBalance'] =
          (wallet['btcBalance'] ?? 0).toDouble() + amountBtc;

      tx.update(receiverRef, {'wallet': wallet});
    });

    // 4️⃣ Record transaction
    await _txRef.add({
      'type': 'sent',
      'senderId': _uid,
      'receiverId': receiverUserId,
      'amountBtc': amountBtc,
      'note': note ?? 'Sent BTC',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // 🟢 RECEIVE BTC (EXTERNAL / DEMO)
  // ============================================================
  Future<void> receiveBtc({
    required double amountBtc,
    String? note, required String receiverUserId,
  }) async {
    if (amountBtc <= 0) {
      throw Exception('Invalid BTC amount');
    }

    // 1️⃣ Credit wallet
    await _ledger.updateBalances(btcDelta: amountBtc);

    // 2️⃣ Record transaction
    await _txRef.add({
      'type': 'received',
      'senderId': 'external',
      'receiverId': _uid,
      'amountBtc': amountBtc,
      'note': note ?? 'Received BTC',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // 🔁 STREAM USER TRANSACTIONS
  // ============================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> transactionsStream() {
    return _txRef
        .where('senderId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  Future<void> recordTransaction({
  required String senderId,
  required String receiverId,
  required double amountBtc,
  required double amountLocal,
  required String type,
  String? note,
}) async {
  await FirebaseFirestore.instance.collection('transactions').add({
    'senderId': senderId,
    'receiverId': receiverId,
    'amountBtc': amountBtc,
    'amountLocal': amountLocal,
    'type': type, // deposit | withdraw | sent | received | convert
    'note': note,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

}
