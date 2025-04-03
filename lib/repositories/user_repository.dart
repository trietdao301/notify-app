import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/user.dart';

abstract class UserRepository {
  Future<User> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore db;

  UserRepositoryImpl({required this.db});

  @override
  Future<User> getUser(String userId) async {
    try {
      final docSnapshot =
          await db
              .collection('users')
              .doc(userId) // Fetch the document directly by ID
              .get();

      if (!docSnapshot.exists) {
        // Check if the document exists
        throw Exception('User not found');
      }

      final docData = docSnapshot.data();
      if (docData == null) {
        // Additional null check for safety
        throw Exception('User data is null');
      }

      return User.fromFirestore(docData, userId);
    } catch (e, stackTrace) {
      throw Exception('Failed to get user: $e (Stack: $stackTrace)');
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await db
          .collection('users')
          .doc(userId)
          .set(
            data,
            SetOptions(merge: true), // Merge with existing data
          );
    } catch (e, stackTrace) {
      throw Exception('Failed to update user: $e (Stack: $stackTrace)');
    }
  }
}
