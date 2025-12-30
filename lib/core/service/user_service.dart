import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===============================
  // PUBLIC METHOD: CREATE USER
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

    // Prevent duplicate creation
    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      return; // user already exists
    }

    final accountNumber = _generateAccountNumber();

    await docRef.set({
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'country': country,
      'accountNumber': accountNumber,
      'emailVerified': user.emailVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'wallet': {
        'btcBalance': 0.0025, // mock BTC
        'localBalance': 100.0, // mock USD
        'currency': 'USD',
        'address': _generateMockBtcAddress(),
      },
    });
  }

  // ===============================
  // ACCOUNT NUMBER GENERATOR
  // ===============================
  String _generateAccountNumber() {
    final random = Random();
    final part1 = random.nextInt(9000) + 1000;
    final part2 = random.nextInt(9000) + 1000;
    return 'LP-$part1-$part2';
  }

  // ===============================
  // MOCK BTC ADDRESS (LEARNING)
  // ===============================
  String _generateMockBtcAddress() {
    return 'bc1q${Random().nextInt(999999999)}mock';
  }
}
