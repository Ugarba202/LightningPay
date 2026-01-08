import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads a profile image to Firebase Storage and returns the download URL.
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final uid = user.uid;
      // Define the path: profile_images/{uid}.jpg
      // We overwrite the same file to save space and keep it simple.
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      // Upload the file
      final _ = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get and return the download URL
      return await ref.getDownloadURL();
    } catch (e) {
      print('ProfileService: Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Removes the profile image from Firebase Storage.
  Future<void> deleteProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.delete();
    } catch (e) {
      print('Error deleting profile image: $e');
    }
  }
}
