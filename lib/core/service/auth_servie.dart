import 'package:firebase_auth/firebase_auth.dart';

class AuthServie {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
