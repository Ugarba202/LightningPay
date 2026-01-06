import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletStreamService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔥 Live wallet stream (BTC + local)
  Stream<Map<String, dynamic>> walletStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) {
        throw Exception('User data not found');
      }

      return Map<String, dynamic>.from(data['wallet'] ?? {});
    });
  }
}
