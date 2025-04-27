import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notifyapp/configs/app_config.dart';
import 'package:notifyapp/fcm/message_processor.dart';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/push_notification.dart';

// ignore_for_file: avoid_print, constant_identifier_names
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    print("Background message received: ${message.messageId}");
    print("Message data: ${message.data}");
    String propertyId =
        message.data[AppConfig.PROPERTY_ID_KEY_FROM_PUSH_NOTIFICATION];
    if (kIsWeb) {
      print("Background handler skipped - web platform not supported");
      return;
    }

    final localNotifications = FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.max,
          color: Color(0xFF607D8B),
          styleInformation: DefaultStyleInformation(true, true),
        );

    Map<FieldToSubscribe, Change> changes = MessageProcessor.processMessage(
      propertyId,
      message,
    );

    PushNotification pushNotification = PushNotification(
      propertyId: propertyId,
      changes: changes,
    );

    final String notificationBody = pushNotification.getBody();

    await localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().hashCode,
      'Property ${pushNotification.propertyId} Update',
      notificationBody,
      const NotificationDetails(android: androidDetails),
    );

    print(
      "Background notification displayed for property: ${pushNotification.propertyId}",
    );
  } catch (e, stackTrace) {
    print("Error in background message handler: $e");
    print("Stack trace: $stackTrace");
  }
}
