import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef {
    return _firestore.collection('users').doc(_uid);
  }

  // ===============================
  // 📡 REAL-TIME WALLET STREAM
  // ===============================
  Stream<Map<String, dynamic>> walletStream() {
    return _userRef.snapshots().map((doc) {
      final data = doc.data();
      if (data == null) throw Exception('User not found');

      final wallet = data['wallet'] as Map<String, dynamic>;
      return {
        'btcBalance': (wallet['btcBalance'] ?? 0).toDouble(),
        'localBalance': (wallet['localBalance'] ?? 0).toDouble(),
        'currency': wallet['currency'],
        'address': wallet['address'],
        'accountNumber': data['accountNumber'],
        'username': data['username'],
      };
    });
  }

  // ===============================
  // ➕ ADD LOCAL BALANCE (Deposit)
  // ===============================
  Future<void> addLocal(double amount) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(_userRef);
      final wallet = snap.data()!['wallet'] as Map<String, dynamic>;

      final current = (wallet['localBalance'] ?? 0).toDouble();

      tx.update(_userRef, {
        'wallet.localBalance': current + amount,
      });
    });
  }

  // ===============================
  // ➖ SUBTRACT LOCAL BALANCE (Withdraw)
  // ===============================
  Future<void> subtractLocal(double amount) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than zero');
    }

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(_userRef);
      final wallet = snap.data()!['wallet'] as Map<String, dynamic>;

      final current = (wallet['localBalance'] ?? 0).toDouble();

      if (current < amount) {
        throw Exception('Insufficient balance');
      }

      tx.update(_userRef, {
        'wallet.localBalance': current - amount,
      });
    });
  }
}
