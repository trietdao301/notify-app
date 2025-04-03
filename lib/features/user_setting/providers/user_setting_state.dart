import 'package:notifyapp/models/enums/allow_notification_setting.dart';
import 'package:notifyapp/models/enums/day.dart';
import 'package:notifyapp/models/user_setting.dart';

enum UserSettingConcreteState {
  initial,
  loading,
  error,
  fetchedSetting,
  invalidSelectedTimeError,
}

class UserSettingState {
  final UserSetting userSetting;
  final UserSettingConcreteState state;
  final String message;

  UserSettingState({
    this.state = UserSettingConcreteState.initial,
    UserSetting? userSetting,
    this.message = "",
  }) : userSetting = userSetting ?? UserSetting();

  UserSettingState copyWith({
    UserSetting? userSetting,
    UserSettingConcreteState? state,
    String? message,
  }) {
    return UserSettingState(
      userSetting: userSetting ?? this.userSetting,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
}
