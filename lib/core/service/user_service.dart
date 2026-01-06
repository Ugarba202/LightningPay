import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'currency_mapper.dart';
import 'rate_service.dart';


class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===============================
  // CREATE USER PROFILE
  // ===============================
  Future<void> createUserProfile({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String country,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final uid = user.uid;
    final docRef = _firestore.collection('users').doc(uid);

    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    final currency = CurrencyMapper.fromCountry(country);
    final accountNumber = _generateAccountNumber();

    final rateService = RateService();
    const initialBtc = 100.0;
    final convertedLocal = rateService.btcToLocal(
      btcAmount: initialBtc,
      currency: currency,
    );

    await docRef.set({
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'country': country,
      'currency': currency,
      'accountNumber': accountNumber,
      'emailVerified': user.emailVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'wallet': {
        'btcBalance': initialBtc,
        'localBalance': convertedLocal,
        'currency': currency,
        'address': _generateMockBtcAddress(),
      },
    });
  }

  // ===============================
  // ACCOUNT NUMBER
  // ===============================
  String _generateAccountNumber() {
    final random = Random();
    return 'LP-${random.nextInt(9000) + 1000}-${random.nextInt(9000) + 1000}';
  }

  // ===============================
  // GET USER PROFILE
  // ===============================
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // ===============================
  // MOCK BTC ADDRESS
  // ===============================
  String _generateMockBtcAddress() {
    return 'bc1q${Random().nextInt(999999999)}mock';
  }
}
