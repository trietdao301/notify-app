import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifyapp/fcm_service/helpers/display_notification.dart';
import 'package:notifyapp/fcm_service/helpers/message_processor.dart';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/push_notification.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';

class ForegroundNotificationHandler {
  final FirebaseAuth auth;
  final FlutterLocalNotificationsPlugin localNotification;
  final CacheSubscriptionService cacheSubscriptionService;
  ForegroundNotificationHandler({
    required this.auth,
    required this.localNotification,
    required this.cacheSubscriptionService,
  });

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    const PROPERTY_ID_KEY = "propertyId";
    print("Foreground message received: ${message.messageId}");
    try {
      if (auth.currentUser == null) {
        print("Current user is null, but notification comes");
        return;
      }
      if (message.data.isNotEmpty) {
        final String? propertyId = message.data[PROPERTY_ID_KEY]?.toString();
        if (propertyId == null) {
          print("No propertyId in notification");
          return;
        }
        Subscription subscription = await getActiveSubscriptionForThisProperty(
          propertyId,
        );

        Map<FieldToSubscribe, Change> changes =
            await MessageProcessor.processMessage(
              propertyId,
              message,
              subscription,
            );

        if (changes.isEmpty) {
          print("changes is empty");
          return;
        }
        print("changes: $changes");
        PushNotification pushNotification = PushNotification(
          propertyId: propertyId,
          changes: changes,
        );
        await displayNotification(pushNotification, localNotification);
      }
    } catch (e) {
      print("Error in foreground message handler: $e");
    }
  }

  Future<Subscription> getActiveSubscriptionForThisProperty(
    String propertyId,
  ) async {
    List<Subscription> activeSubscriptions = await cacheSubscriptionService
        .getActiveSubscriptionsByUser(auth.currentUser!.uid);
    Subscription subscription = activeSubscriptions.firstWhere(
      (each) => each.propertyId == propertyId,
      orElse:
          () =>
              throw Exception('No subscription found for property $propertyId'),
    );
    return subscription;
  }
}
