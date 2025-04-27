import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/user.dart';
import 'package:notifyapp/models/user.dart' as UserModel;
import 'package:notifyapp/models/user_setting.dart';

abstract class UserRepository {
  Future<User> getUser(String userId);
  Future<void> updateUser(
    final String documentId,
    final bool? isVerified,
    final UserSetting? userSetting,
    final UserModel.Role? role,
    final String? fcmToken,
  );
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
  Future<void> updateUser(
    final String documentId,
    final bool? isVerified,
    final UserSetting? userSetting,
    final UserModel.Role? role,
    final String? fcmToken,
  ) async {
    try {
      final Map<String, dynamic> data = {};

      if (isVerified != null) {
        data['isVerified'] = isVerified;
      }
      if (userSetting != null) {
        data['userSetting'] = userSetting.toFirestore();
      }
      if (role != null) {
        data['role'] = role.value;
      }
      if (fcmToken != null) {
        data['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
      }

      await db
          .collection('users')
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e, stackTrace) {
      throw Exception('Failed to update user: $e (Stack: $stackTrace)');
    }
  }
}
