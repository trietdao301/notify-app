import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { admin, user, anonymous }

class User {
  final bool isVerified; // For ownership verification
  final List<String> ownedProperty; // List of houseIds for owned properties
  final Role role; // User role (e.g., 'admin', 'user', 'anonymous')

  User({
    required this.isVerified,
    required this.ownedProperty,
    required this.role,
  });

  // From Firestore
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      isVerified: data['isVerified'] ?? false,
      ownedProperty: List<String>.from(data['ownedProperty'] ?? []),
      role: Role.values.firstWhere(
        (r) => r.toString() == 'Role.${data['role']}',
        orElse: () => Role.anonymous, // Default to 'anonymous'
      ),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'isVerified': isVerified,
      'ownedProperty': ownedProperty,
      'role': role.toString().split('.').last, // Store enum as string
    };
  }
}
