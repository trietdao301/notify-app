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
  bool _isDisposed = false;
  final SubscriptionService subscriptionService;

  UserSettingsNotifier({required this.ref, required this.subscriptionService})
    : super(UserSettingState()) {
    fetchCurrentUserSetting(); // Initial fetch
    _setupListener();
  }

  @override
  void dispose() {
    _isDisposed = true;
    print("UserSettingsNotifier disposed at: ${DateTime.now()}");
    super.dispose();
  }

  void _setupListener() {
    ref.listen<CurrentUserProviderState>(currentUserProvider, (previous, next) {
      print(
        "currentUserProvider state changed: ${next.state} - ${DateTime.now()}",
      );
      if (_isDisposed) return;
      _updateStateFromCurrentUser(next);
    });
  }

  Future<void> fetchCurrentUserSetting() async {
    print("fetchCurrentUserSetting started: ${DateTime.now()}");
    if (_isDisposed) return;

    final currentUserNotifier = ref.read(currentUserProvider.notifier);
    final currentUserState = ref.read(currentUserProvider);

    // If the state is initial or loading, trigger a fetch
    if (currentUserState.state == CurrentUserProviderConcreteState.initial ||
        currentUserState.state == CurrentUserProviderConcreteState.loading) {
      print(
        "Triggering fetchCurrentUser due to initial/loading state: ${DateTime.now()}",
      );
      await currentUserNotifier.fetchCurrentUser();
    }

    final updatedState = ref.read(currentUserProvider);
    print(
      "fetchCurrentUserSetting completed: ${updatedState.state} - ${DateTime.now()}",
    );
    _updateStateFromCurrentUser(updatedState);
  }

  void _updateStateFromCurrentUser(CurrentUserProviderState currentUser) {
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
    if (_isDisposed) return;
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

  Future<void> updateSettingDatabase() async {
    print("updateSettingDatabase started: ${DateTime.now()}");
    if (_isDisposed) {
      print("updateSettingDatabase aborted: Notifier disposed");
      return;
    }

    final currentUserNotifier = ref.read(currentUserProvider.notifier);
    try {
      state = state.copyWith(
        state: UserSettingConcreteState.loading,
        message: "Saving settings...",
      );
      print("Set loading state: ${DateTime.now()}");

      await currentUserNotifier.updateUserSetting(state.userSetting);
      print("updateUserSetting completed: ${DateTime.now()}");

      await subscriptionService.updateAllCurrentSubscriptionSetting(
        state.userSetting,
      );
      print("updateAllCurrentSubscriptionSetting completed: ${DateTime.now()}");

      if (!_isDisposed) {
        state = state.copyWith(
          state: UserSettingConcreteState.fetchedSetting,
          message: "Settings saved to database",
        );
        print("Set success state: ${DateTime.now()}");
      } else {
        print("Skipped success state update: Notifier disposed");
      }
    } catch (e) {
      print("updateSettingDatabase error: $e - ${DateTime.now()}");
      if (!_isDisposed) {
        state = state.copyWith(
          state: UserSettingConcreteState.error,
          message: "Error while updating settings to database: $e",
        );
      }
      rethrow;
    }
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
      );
    });
