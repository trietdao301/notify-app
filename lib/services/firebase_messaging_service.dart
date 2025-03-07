import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: unused_import
import 'package:http/http.dart' as http;
import 'package:notifyapp/services/firebase_messaging_android.dart';
import 'package:notifyapp/services/firebase_messaging_ios.dart';
import 'package:notifyapp/services/firebase_messaging_web.dart';

class FirebaseMessagingService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initializes the Firebase Messaging service.
  ///
  /// This function is called when the app is started.
  ///
  /// The function checks the platform and initializes the service
  /// accordingly.
  ///
  /// It also sets up the event listeners for the service.
  Future<void> initialize() async {
    // Check the platform and initialize the service accordingly
    if (kIsWeb) {
      // Initialize the service for the web
      await FirebaseMessagingWeb().initialize();
    } else if (Platform.isAndroid) {
      // Initialize the service for Android
      await FirebaseMessagingAndroid().initialize();
    } else if (Platform.isIOS) {
      // Initialize the service for iOS
      await FirebaseMessagingIOS().initialize();
    }

    // Set up the event listeners for the service
    // The onMessage event is triggered when the app is in the foreground
    // and a notification is received
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // The onMessageOpenedApp event is triggered when the app is started
    // from a notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }

  /// Handles incoming foreground messages.
  ///
  /// Displays a local notification if the platform is not web-based
  /// and the incoming message contains a notification payload.
  ///
  /// [message] is the incoming remote message that contains the notification.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print("Foreground message received: ${message.notification?.title}");
    final notification = message.notification;

    if (kIsWeb) {
      return;
    }
    // Handle notifications for Android and iOS
    if (notification != null && !kIsWeb) {
      await _localNotifications.show(
        notification.hashCode, // Unique identifier for the notification
        notification.title, // Notification title
        notification.body, // Notification body
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel name
            importance: Importance.max, // Notification importance
            priority: Priority.high, // Notification priority
          ),
        ),
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Add your navigation logic here
  }
}
