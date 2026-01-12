import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads a profile image to Firebase Storage and returns the download URL.
  Future<String?> uploadProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final uid = user.uid;
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');
    final bytes = await imageFile.readAsBytes();

    // 1. Upload Phase
    try {
      final task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      await task; // This throws providing the exact upload error
    } catch (e) {
      if (e.toString().contains('object-not-found')) {
         // If write fails with object-not-found, the Bucket is likely missing or rules are blocking
         throw Exception('Configuration Error: Storage Bucket not found or invalid.');
      }
      throw Exception('Upload failed: ${e.toString()}');
    }

    // 2. Retrieval Phase
    try {
      // Small delay to ensure consistency
      await Future.delayed(const Duration(milliseconds: 1000));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to retrieve image URL: ${e.toString()}');
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
