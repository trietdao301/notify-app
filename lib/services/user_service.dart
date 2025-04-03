import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/models/user.dart' as UserModel;
import 'package:notifyapp/repositories/user_repository.dart';

abstract class UserService {
  Future<UserModel.User> getCurrentUser();
  Future<void> updateUser(UserModel.User updatedUser);
}

class UserServiceImpl implements UserService {
  final UserRepository userRepository;
  final FirebaseAuth auth;
  UserServiceImpl({required this.userRepository, required this.auth});

  @override
  Future<UserModel.User> getCurrentUser() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("No current user");
    }
    String userId = currentUser.uid;
    UserModel.User user = await userRepository.getUser(userId);

    return user;
  }

  @override
  Future<void> updateUser(UserModel.User updatedUser) async {
    try {
      // Ensure the current user is authenticated
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found");
      }

      // Use the documentId from the updatedUser to update the Firestore document
      await userRepository.updateUser(
        updatedUser.documentId,
        updatedUser.toFirestore(),
      );
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }
}
