import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserLookupService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Future<AppUser?> findByUsername(String username) async {
    final cleanUsername = username.replaceAll('@', '').trim();

    final query = await _usersRef
        .where('username', isEqualTo: cleanUsername)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return AppUser.fromFirestore(query.docs.first.data());
  }
}
