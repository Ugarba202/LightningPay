import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConvertService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> convert({
    required bool btcToLocal,
    required double amount,
    required double rate, // mock rate
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final userRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(userRef);
      if (!snapshot.exists) throw Exception('Wallet not found');

      final wallet = snapshot['wallet'];

      double btc = (wallet['btcBalance'] ?? 0).toDouble();
      double local = (wallet['localBalance'] ?? 0).toDouble();

      if (btcToLocal) {
        if (btc < amount) throw Exception('Insufficient BTC');

        btc -= amount;
        local += amount * rate;
      } else {
        if (local < amount) throw Exception('Insufficient local balance');

        local -= amount;
        btc += amount / rate;
      }

      tx.update(userRef, {
        'wallet.btcBalance': btc,
        'wallet.localBalance': local,
      });

      tx.set(_firestore.collection('transactions').doc(), {
        'type': 'convert',
        'direction': btcToLocal ? 'BTC_TO_LOCAL' : 'LOCAL_TO_BTC',
        'amount': amount,
        'rate': rate,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> convertBtcToLocal({required double btcAmount}) async {}
}
