// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/exceptions/InvalidSelectedTimeException.dart';
import 'package:notifyapp/features/user_setting/providers/user_setting_state.dart';
import 'package:notifyapp/models/enums/allow_notification_setting.dart';
import 'package:notifyapp/models/enums/day.dart';
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/repositories/subscription_repository.dart';
import 'package:notifyapp/services/subscription_service.dart';
import 'package:notifyapp/shared/providers/current_user_provider.dart';

class UserSettingsNotifier extends StateNotifier<UserSettingState> {
  final Ref ref;
  final SubscriptionService subscriptionService;

  UserSettingsNotifier({required this.ref, required this.subscriptionService})
    : super(UserSettingState());

  @override
  void dispose() {
    print("UserSettingsNotifier disposed at: ${DateTime.now()}");
    super.dispose();
  }

  Future<void> fetchCurrentUserSetting() async {
    final currentUserState = ref.watch(currentUserProvider);
    print("fetchCurrentUserSetting started: ${DateTime.now()}");
    // If the state is initial or loading, trigger a fetch
    if (currentUserState.state == CurrentUserProviderConcreteState.initial ||
        currentUserState.state == CurrentUserProviderConcreteState.loading) {
      print(
        "Triggering fetchCurrentUser due to initial/loading state: ${DateTime.now()}",
      );
    }
    print(
      "fetchCurrentUserSetting completed: ${currentUserState.state} - ${DateTime.now()}",
    );
    _updateStateFromCurrentUser(currentUserState);
  }

  void _updateStateFromCurrentUser(CurrentUserProviderState currentUser) {
    print(mounted);
    if (currentUser.state ==
        CurrentUserProviderConcreteState.fetchedCurrentUser) {
      if (currentUser.currentUser != null) {
        final userSetting = currentUser.currentUser!.userSetting;
        state = state.copyWith(
          userSetting: userSetting,
          state: UserSettingConcreteState.fetchedSetting,
          message: "User settings fetched successfully",
        );
      }
    } else if (currentUser.state == CurrentUserProviderConcreteState.error) {
      state = state.copyWith(
        state: UserSettingConcreteState.error,
        message: "Error fetching user settings: ${currentUser.message}",
      );
    } else if (currentUser.state == CurrentUserProviderConcreteState.loading) {
      state = state.copyWith(
        state: UserSettingConcreteState.loading,
        message: "Loading user settings",
      );
    } else if (currentUser.state == CurrentUserProviderConcreteState.initial) {
      state = state.copyWith(
        state: UserSettingConcreteState.initial,
        message: "Initial state",
      );
    }
  }

  void updateSettingState({
    AllowNotificationSetting? notificationSetting,
    ReceiveWindow? commonWindow,
    Map<Day, ReceiveWindow>? customWindows,
    Frequency? frequency,
  }) {
    print(mounted);
    try {
      final updatedSetting = UserSetting(
        notificationSetting:
            notificationSetting ?? state.userSetting.notificationSetting,
        commonWindow: commonWindow ?? state.userSetting.commonWindow,
        customWindows: customWindows ?? state.userSetting.customWindows,
        frequency: frequency ?? state.userSetting.frequency,
      );
      state = state.copyWith(
        userSetting: updatedSetting,
        state: UserSettingConcreteState.fetchedSetting,
        message: "Settings updated locally",
        isSaved: false,
      );
    } on InvalidSelectedTimeException catch (e) {
      state = state.copyWith(
        state: UserSettingConcreteState.invalidSelectedTimeError,
        message: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        state: UserSettingConcreteState.error,
        message: "Unexpected error: $e",
      );
    }
  }

  Future<void> saveSetting() async {
    print("updateSettingDatabase started: ${DateTime.now()}");
    final currentUserNotifier = ref.read(currentUserProvider.notifier);

    print("Set loading state: ${DateTime.now()}");

    state = state.copyWith(
      state: UserSettingConcreteState.loading,
      message: "Saving settings",
    );
    print(mounted);

    print("updateUserSetting completed: ${DateTime.now()}");
    print(mounted);
    await subscriptionService.updateAllCurrentSubscriptionSetting(
      state.userSetting,
    );

    /// This function has to be after any functions because it changes
    /// currentUserProvider state which will dispose this provider
    /// which will prevent any further functions to get executed or throw error.
    await currentUserNotifier.updateUserSetting(state.userSetting);
  }
}

final userSettingScreenProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettingState>((ref) {
      final FirebaseMessaging fcm = FirebaseMessaging.instance;
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final SubscriptionRepository subscriptionRepository =
          SubscriptionRepositoryImpl(db: db);

      final SubscriptionService subscriptionService = SubscriptionServiceImp(
        fcm: fcm,
        auth: auth,
        subscriptionRepository: subscriptionRepository,
      );
      return UserSettingsNotifier(
        subscriptionService: subscriptionService,
        ref: ref,
      )..fetchCurrentUserSetting();
    });
