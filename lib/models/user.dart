import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/enums/day.dart';
import 'package:notifyapp/models/enums/allow_notification_setting.dart';
import 'package:notifyapp/models/user_setting.dart';

enum Role { admin, user, anonymous }

class User {
  final bool isVerified;
  final UserSetting userSetting;
  final Role role;
  final String documentId;
  final Set<String> fcmToken;
  User({
    required this.isVerified,
    required this.userSetting,
    required this.role,
    required this.documentId,
    required this.fcmToken,
  });

  // From Firestore
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      documentId: documentId,
      isVerified: data['isVerified'] as bool? ?? false,
      fcmToken:
          (data['fcmToken'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toSet(),
      userSetting:
          data['userSetting'] != null
              ? UserSetting.fromJson(
                data['userSetting'] as Map<String, dynamic>,
              )
              : UserSetting(), // Provide a default if null
      role: Role.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => Role.anonymous,
      ),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'isVerified': isVerified,
      'userSetting': userSetting.toFirestore(),
      'role': role.name,
      'fcmToken': fcmToken,
    };
  }
}
