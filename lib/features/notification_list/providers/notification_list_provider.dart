import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/repositories/property_notification_repository.dart';
import 'package:notifyapp/features/notification_list/providers/notification_list_state.dart';
import 'package:notifyapp/models/property_notification.dart';
import 'package:notifyapp/services/property_notification_service.dart';
import 'package:notifyapp/shared/providers/notification_stream_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationListScreenNotifier
    extends StateNotifier<NotificationListScreenState> {
  final PropertyNotificationService propertyNotificationService;
  final FirebaseAuth auth;
  final Ref ref;

  NotificationListScreenNotifier({
    required this.auth,
    required this.propertyNotificationService,
    required this.ref,
  }) : super(NotificationListScreenState()) {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    ref.listen<AsyncValue<List<PropertyNotification>>>(
      notificationStreamProvider,
      (previous, next) {
        print(
          'NotificationListScreenNotifier: Previous: $previous, Next: $next',
        );
        next.when(
          data: (notifications) {
            print('Data: ${notifications.length} notifications');
            state = state.copyWith(
              state:
                  NotificationListScreenConcreteState.fetchedAllNotifications,
              notificationList: notifications,
              message: 'Notifications updated',
            );
          },
          loading: () {
            print('Loading');
            state = state.copyWith(
              state: NotificationListScreenConcreteState.loading,
            );
          },
          error: (error, stack) {
            print('Error: $error');
            state = state.copyWith(
              state: NotificationListScreenConcreteState.error,
              message: 'Error: $error',
            );
          },
        );
      },
    );
  }

  Future<void> getUnreadNotifications() async {
    state = state.copyWith(
      state:
          state.page > 0
              ? NotificationListScreenConcreteState.fetchingMore
              : NotificationListScreenConcreteState.loading,
    );
    try {
      if (auth.currentUser == null) {
        throw Exception("Current user is null");
      }
      List<PropertyNotification> result = await propertyNotificationService
          .getNotificationsByUser(userId: auth.currentUser!.uid);
      state = state.copyWith(
        state: NotificationListScreenConcreteState.fetchedAllNotifications,
        notificationList: result,
        message: 'Fetching successfully',
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        state: NotificationListScreenConcreteState.error,
        message: 'Error message: ${e.toString()}',
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Get current time in milliseconds since epoch (UTC)
      final currentTimeInMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('property_notifications')
          .doc(notificationId)
          .update({
            'isRead': true,
            'readAt': currentTimeInMillis, // Integer milliseconds since epoch
          });
      print(
        'Marked notification $notificationId as read at $currentTimeInMillis',
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      state = state.copyWith(
        state: NotificationListScreenConcreteState.error,
        message: 'Failed to mark as read: $e',
      );
    }
  }
}

final notificationListNotifierProvider = StateNotifierProvider<
  NotificationListScreenNotifier,
  NotificationListScreenState
>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final propertyNotificationRepository = PropertyNotificationRepositoryImpl(
    db: firestore,
  );
  final propertyNotificationService = PropertyNotificationServiceImpl(
    auth: auth,
    propertyNotificationRepository: propertyNotificationRepository,
  );
  return NotificationListScreenNotifier(
    auth: auth,
    propertyNotificationService: propertyNotificationService,
    ref: ref,
  )..getUnreadNotifications();
});
