import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch current user's wallet data
  Future<Map<String, dynamic>> getMyWallet() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      throw Exception('User wallet not found');
    }

    final data = doc.data()!;
    final wallet = data['wallet'] as Map<String, dynamic>;

    return {
      'btcBalance': wallet['btcBalance'] ?? 0.0,
      'localBalance': wallet['localBalance'] ?? 0.0,
      'currency': wallet['currency'],
      'address': wallet['address'],
    };
  }

  /// 🔐 SAFELY UPDATE BALANCES (ATOMIC)
  Future<void> updateBalancesSafely({
    required double btcDelta,
    required double localDelta,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final docRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Wallet not found');
      }

      final data = snapshot.data()!;
      final wallet = Map<String, dynamic>.from(data['wallet']);

      final double currentBtc =
          (wallet['btcBalance'] ?? 0.0).toDouble();
      final double currentLocal =
          (wallet['localBalance'] ?? 0.0).toDouble();

      final double newBtc = currentBtc + btcDelta;
      final double newLocal = currentLocal + localDelta;

      // 🚨 Prevent negative balances
      if (newBtc < 0) {
        throw Exception('Insufficient BTC balance');
      }

      if (newLocal < 0) {
        throw Exception('Insufficient local balance');
      }

      wallet['btcBalance'] = newBtc;
      wallet['localBalance'] = newLocal;

      transaction.update(docRef, {
        'wallet': wallet,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
