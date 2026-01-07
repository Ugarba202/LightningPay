import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletLedgerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔐 Get current authenticated user ID
  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  /// 📌 Reference to current user's wallet document
  DocumentReference<Map<String, dynamic>> get _walletRef {
    return _firestore.collection('users').doc(_uid);
  }

  // ============================================================
  // 🔍 READ WALLET (Single Source of Truth)
  // ============================================================
  Future<Map<String, dynamic>> fetchWallet() async {
    final snapshot = await _walletRef.get();

    if (!snapshot.exists) {
      throw Exception('Wallet not found');
    }

    final data = snapshot.data();
    if (data == null || data['wallet'] == null) {
      throw Exception('Wallet data missing');
    }

    return Map<String, dynamic>.from(data['wallet']);
  }

  // ============================================================
  // 🛡️ BALANCE CHECKS
  // ============================================================
  Future<void> ensureSufficientBalance({
    double? requiredBtc,
    double? requiredLocal,
  }) async {
    final wallet = await fetchWallet();

    final btcBalance = (wallet['btcBalance'] ?? 0).toDouble();
    final localBalance = (wallet['localBalance'] ?? 0).toDouble();

    if (requiredBtc != null && btcBalance < requiredBtc) {
      throw Exception('Insufficient BTC balance');
    }

    if (requiredLocal != null && localBalance < requiredLocal) {
      throw Exception('Insufficient local balance');
    }
  }

  // ============================================================
  // 🔄 ATOMIC WALLET UPDATE (CORE ENGINE)
  // ============================================================
  Future<void> updateBalances({
    double btcDelta = 0,
    double localDelta = 0,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(_walletRef);

      if (!snapshot.exists) {
        throw Exception('Wallet not found');
      }

      final data = snapshot.data();
      if (data == null || data['wallet'] == null) {
        throw Exception('Wallet structure invalid');
      }

      final wallet = Map<String, dynamic>.from(data['wallet']);

      final currentBtc = (wallet['btcBalance'] ?? 0).toDouble();
      final currentLocal = (wallet['localBalance'] ?? 0).toDouble();

      final newBtc = currentBtc + btcDelta;
      final newLocal = currentLocal + localDelta;

      if (newBtc < 0 || newLocal < 0) {
        throw Exception('Balance cannot go negative');
      }

      wallet['btcBalance'] = newBtc;
      wallet['localBalance'] = newLocal;

      transaction.update(_walletRef, {'wallet': wallet});
    });
  }
}
