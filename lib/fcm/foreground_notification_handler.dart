import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifyapp/configs/app_config.dart';
import 'package:notifyapp/fcm/message_processor.dart';
import 'package:notifyapp/fcm/helpers/displayNotification.dart';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/push_notification.dart';

class ForegroundNotificationHandler {
  final FirebaseAuth auth;
  final FlutterLocalNotificationsPlugin localNotification;
  ForegroundNotificationHandler({
    required this.auth,
    required this.localNotification,
  });

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    print("Foreground message received: ${message.messageId}");
    try {
      if (auth.currentUser == null) {
        print("Current user is null, but notification comes");
        return;
      }
      if (message.data.isNotEmpty) {
        final String? propertyId =
            message.data[AppConfig.PROPERTY_ID_KEY_FROM_PUSH_NOTIFICATION]
                ?.toString();
        if (propertyId == null) {
          print("No propertyId in notification");
          return;
        }

        Map<FieldToSubscribe, Change> changes = MessageProcessor.processMessage(
          propertyId,
          message,
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
}
