import 'package:notifyapp/models/milliseconds_since_epoch.dart';
import 'package:notifyapp/models/user_setting.dart';

enum Role {
  admin("admin"),
  user("user"),
  anonymous("anonymous");

  final String value;
  const Role(this.value);
}

class User {
  final bool isVerified;
  final UserSetting userSetting;
  final Role role;
  final String documentId;
  final Set<String> fcmTokens;
  final MillisecondsSinceEpoch? lastReceived;

  User({
    required this.isVerified,
    required this.userSetting,
    required this.role,
    required this.documentId,
    required this.fcmTokens,
    required this.lastReceived,
  });

  // From Firestore
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    final lastReceivedData = data['lastReceived'];
    return User(
      documentId: documentId,
      isVerified: data['isVerified'] as bool? ?? false,
      fcmTokens:
          (data['fcmTokens'] as List<dynamic>? ?? [])
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
      lastReceived:
          lastReceivedData != null
              ? MillisecondsSinceEpoch(milliseconds: lastReceivedData as int)
              : null, // Set to null if not present
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'isVerified': isVerified,
      'userSetting': userSetting.toFirestore(),
      'role': role.name,
      'fcmTokens': fcmTokens.toList(), // Convert Set to List for Firestore
      if (lastReceived != null) 'lastReceived': lastReceived!.milliseconds,
    };
  }
}
