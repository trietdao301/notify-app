import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notifyapp/fcm_service/background_handler.dart';
import 'package:notifyapp/fcm_service/fcm_init/firebase_messaging_android.dart';
import 'package:notifyapp/fcm_service/fcm_init/firebase_messaging_ios.dart';
import 'package:notifyapp/fcm_service/fcm_init/firebase_messaging_web.dart';
import 'package:notifyapp/fcm_service/message_processor.dart';
import 'package:notifyapp/models/Change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/push_notification.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';
import 'dart:js' as js; // Add this import for web

// ignore_for_file: avoid_print, constant_identifier_names
class FirebaseMessagingService {
  static const PROPERTY_ID_KEY = "propertyId";
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final CacheSubscriptionService cacheSubscriptionService;
  final FirebaseAuth auth;

  FirebaseMessagingService({
    required this.cacheSubscriptionService,
    required this.auth,
  });

  Future<void> initialize() async {
    if (kIsWeb) {
      await FirebaseMessagingWeb().initialize();
    } else if (Platform.isAndroid) {
      await FirebaseMessagingAndroid().initialize();
    } else if (Platform.isIOS) {
      await FirebaseMessagingIOS().initialize();
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print("Foreground message received: ${message.messageId}");
    try {
      if (message.data.isNotEmpty) {
        if (auth.currentUser == null) {
          print("Notifications come, but current user is null");
          return;
        }
        final String? propertyId = message.data[PROPERTY_ID_KEY]?.toString();
        if (propertyId == null) {
          print("No propertyId in notification");
          return;
        }
        Subscription subscription = await getSubscriptionForThisProperty(
          propertyId,
        );
        Map<FieldCanChange, Change> changes =
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
        await displayNotification(pushNotification);
      }
    } catch (e) {
      print("Error in foreground message handler: $e");
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
  }

  Future<Subscription> getSubscriptionForThisProperty(String propertyId) async {
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

  Future<void> displayNotification(PushNotification pushNotification) async {
    final String body = pushNotification.getBody();
    print("Displaying notification: $body");

    if (kIsWeb) {
      js.context.callMethod('showWebNotification', [
        'Property ${pushNotification.propertyId} Update',
        body,
      ]);
    } else {
      // Mobile: Use local notifications
      await _localNotifications.show(
        pushNotification.hashCode,
        'Property ${pushNotification.propertyId} Update',
        body,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.max,
            color: Color(0xFF607D8B),
            styleInformation: DefaultStyleInformation(true, true),
          ),
        ),
      );
    }
  }
}
