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
  final bool isSaved;

  UserSettingState({
    this.state = UserSettingConcreteState.initial,
    UserSetting? userSetting,
    this.message = "",
    this.isSaved = false,
  }) : userSetting = userSetting ?? UserSetting();

  UserSettingState copyWith({
    UserSetting? userSetting,
    UserSettingConcreteState? state,
    bool? isSaved,
    String? message,
  }) {
    return UserSettingState(
      userSetting: userSetting ?? this.userSetting,
      state: state ?? this.state,
      isSaved: isSaved ?? this.isSaved,
      message: message ?? this.message,
    );
  }
}
