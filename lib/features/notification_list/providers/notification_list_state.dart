import 'package:notifyapp/models/property_notification.dart';

enum NotificationListScreenConcreteState {
  loading,
  initial,
  error,
  fetchingMore,
  fetchedAllNotifications,
}

class NotificationListScreenState {
  final NotificationListScreenConcreteState state;
  final String message;
  final int page;
  final List<PropertyNotification> notificationList;

  NotificationListScreenState({
    this.state = NotificationListScreenConcreteState.initial,
    this.message = "",
    this.page = 0,
    this.notificationList = const [],
  });

  NotificationListScreenState copyWith({
    List<PropertyNotification>? notificationList,
    int? page,
    NotificationListScreenConcreteState? state,
    String? message,
  }) {
    return NotificationListScreenState(
      notificationList: notificationList ?? this.notificationList,
      page: page ?? this.page,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
}
