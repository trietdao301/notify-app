// import 'dart:async';
// import 'package:notifyapp/models/User.dart';
// import 'package:riverpod/riverpod.dart';

// class AuthNotifier extends AsyncNotifier<User?> {
//   @override
//   Future<User?> build() async {
//     return _fetchCurrentUser();
//   }

//   Future<User?> _fetchCurrentUser() async {
//     state = const AsyncValue.loading();

//     try {
//       // Create a sample User object
//       final user = User(
//         id: 'abc123',
//         email: 'user@example.com',
//         phone: '+1234567890',
//         isVerified: true,
//         ownedHouses: ['house1', 'house2'],
//         notificationPrefs: NotificationPrefs(
//           email: true,
//           sms: false,
//           app: true,
//         ),
//         alertSettings: AlertSettings(
//           houseIds: ['house1', 'house2'],
//           eventCategories: ['house/pricing', 'house/tax', 'house/assessment'],
//         ),
//         createdAt: DateTime.now(),
//         lastLogin: DateTime.now().subtract(const Duration(days: 3)),
//       );

//       // Update state with the fetched user
//       state = AsyncValue.data(user);
//       return user;
//     } catch (e, stackTrace) {
//       // Update state with error
//       state = AsyncValue.error(e, stackTrace);
//       rethrow;
//     }
//   }
// }

// final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
//   return AuthNotifier();
// });
