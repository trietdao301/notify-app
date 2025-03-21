import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notifyapp/fcm_service/helpers/background_notification_handler.dart';
import 'package:notifyapp/fcm_service/fcm_init/firebase_messaging_android.dart';
import 'package:notifyapp/fcm_service/fcm_init/firebase_messaging_ios.dart';
import 'package:notifyapp/fcm_service/fcm_init/firebase_messaging_web.dart';
import 'package:notifyapp/fcm_service/helpers/foreground_notification_handler.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';

// ignore_for_file: avoid_print, constant_identifier_names
class FirebaseMessagingService {
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
    ForegroundNotificationHandler foregroundNotificationHandler =
        ForegroundNotificationHandler(
          auth: auth,
          localNotification: _localNotifications,
          cacheSubscriptionService: cacheSubscriptionService,
        );

    FirebaseMessaging.onMessage.listen(
      foregroundNotificationHandler.handleForegroundMessage,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  void handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
  }
}
