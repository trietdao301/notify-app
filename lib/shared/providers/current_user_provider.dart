import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/fcm/platforms/android.dart';
import 'package:notifyapp/models/user.dart' as UserModel;
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/repositories/user_repository.dart';
import 'package:notifyapp/services/user_service.dart';

enum CurrentUserProviderConcreteState {
  initial,
  loading,
  error,
  fetchedCurrentUser,
}

class CurrentUserProviderState {
  final UserModel.User? currentUser;
  final String message;
  final CurrentUserProviderConcreteState state;
  CurrentUserProviderState({
    this.message = "",
    this.currentUser = null,
    this.state = CurrentUserProviderConcreteState.initial,
  });

  CurrentUserProviderState copyWith({
    UserModel.User? user,
    CurrentUserProviderConcreteState? state,
    String? message,
  }) {
    return CurrentUserProviderState(
      currentUser: user ?? this.currentUser,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
}

class CurrentUserProviderNotifier
    extends StateNotifier<CurrentUserProviderState> {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  final UserService userService;
  final FirebaseMessaging fcm;

  CurrentUserProviderNotifier({
    required this.auth,
    required this.db,
    required this.userService,
    required this.fcm,
  }) : super(CurrentUserProviderState());

  Future<void> fetchCurrentUserOnFirstBuild() async {
    state = state.copyWith(
      state: CurrentUserProviderConcreteState.loading,
      message: "Fetching current user",
    );
    print("current user is loading.");
    try {
      final UserModel.User user = await userService.getCurrentUser();
      state = state.copyWith(
        user: user,
        state: CurrentUserProviderConcreteState.fetchedCurrentUser,
        message: "Current user is fetched.",
      );
      print("current user is fetched");
    } catch (e) {
      state = state.copyWith(
        user: null,
        state: CurrentUserProviderConcreteState.error,
        message: "Error when fetching current user: $e",
      );
      print("current user is error");
    }
  }

  Future<void> updateUserSetting(UserSetting userSetting) async {
    String? fcmToken = await fcm.getToken();
    if (fcmToken == null) return;

    if (state.currentUser == null) {
      state = state.copyWith(
        state: CurrentUserProviderConcreteState.error,
        message: "No current user available to update",
      );
      return;
    }
    print("updating current user setting: loading");
    state = state.copyWith(
      state: CurrentUserProviderConcreteState.loading,
      message: "Updating user settings",
    );
    try {
      final currentUser = state.currentUser!;

      final updatedUser = UserModel.User(
        isVerified: currentUser.isVerified,
        userSetting: userSetting,
        role: currentUser.role,
        documentId: currentUser.documentId,
        fcmToken: currentUser.fcmToken,
      );

      await userService.updateUser(updatedUser);

      state = state.copyWith(
        user: updatedUser,
        state: CurrentUserProviderConcreteState.fetchedCurrentUser,
        message: "User settings updated in database successfully",
      );
    } catch (e) {
      state = state.copyWith(
        state: CurrentUserProviderConcreteState.error,
        message: "Error updating user settings: $e",
      );
    }
  }
}

final currentUserProvider = StateNotifierProvider<
  CurrentUserProviderNotifier,
  CurrentUserProviderState
>((ref) {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final UserRepository userRepository = UserRepositoryImpl(db: db);
  final UserService userService = UserServiceImpl(
    userRepository: userRepository,
    auth: auth,
  );
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  return CurrentUserProviderNotifier(
    fcm: fcm,
    auth: auth,
    db: db,
    userService: userService,
  )..fetchCurrentUserOnFirstBuild();
});
