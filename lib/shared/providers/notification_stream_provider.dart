import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/models/property_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationStreamNotifier
    extends StreamNotifier<List<PropertyNotification>> {
  final FirebaseAuth auth;

  NotificationStreamNotifier({required this.auth});

  @override
  Stream<List<PropertyNotification>> build() {
    final user = auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('property_notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => PropertyNotification.fromFirestore(doc))
                  .toList(),
        );
  }
}

// Correct provider definition
final notificationStreamProvider = StreamNotifierProvider<
  NotificationStreamNotifier,
  List<PropertyNotification>
>(() {
  final auth = FirebaseAuth.instance;
  return NotificationStreamNotifier(auth: auth);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationStreamProvider);
  return notifications.when(
    data: (notificationList) => notificationList.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
