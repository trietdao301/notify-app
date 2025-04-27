import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifyapp/models/user.dart' as UserModel;
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/repositories/user_repository.dart';

abstract class UserService {
  Future<UserModel.User> getCurrentUser();
  Future<void> updateUser(
    final String documentId,
    final bool? isVerified,
    final UserSetting? userSetting,
    final UserModel.Role? role,
  );
}

class UserServiceImpl implements UserService {
  final UserRepository userRepository;
  final FirebaseAuth auth;
  final FirebaseMessaging fcm;
  UserServiceImpl({
    required this.fcm,
    required this.userRepository,
    required this.auth,
  });

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
  Future<void> updateUser(
    final String documentId,
    final bool? isVerified,
    final UserSetting? userSetting,
    final UserModel.Role? role,
  ) async {
    try {
      // Ensure the current user is authenticated
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw Exception("No authenticated user found");
      }
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      await userRepository.updateUser(
        documentId,
        isVerified,
        userSetting,
        role,
        fcmToken,
      );
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }
}
