
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  // Collection reference
  final CollectionReference<Map<String, dynamic>> byteChewCollection =
      FirebaseFirestore.instance.collection('byteChew');

  // Create or update user data
  Future<void> updateUserData(String role, String name) async {
    await byteChewCollection.doc(uid).set({
      'role': role,
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get existing user data
  Future<Map<String, dynamic>?> getUserData() async {
    final document = await byteChewCollection.doc(uid).get();

    if (document.exists) {
      return document.data();
    }

    return null;
  }

  // Create user data only if it does not exist
  Future<void> createUserData(String role, String name, String email) async {
    final document = byteChewCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);

      if (!snapshot.exists) {
        transaction.set(document, {
          'role': role,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
