import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:notifyapp/fcm_service/helpers/interop_stubs/unsupported.dart'
    if (dart.library.js) 'package:notifyapp/fcm_service/helpers/interop_stubs/web.dart'
    if (dart.library.io) 'package:notifyapp/fcm_service/helpers/interop_stubs/native.dart';

import 'package:notifyapp/models/push_notification.dart';

Future<void> displayNotification(
  PushNotification pushNotification,
  FlutterLocalNotificationsPlugin localNotification,
) async {
  final String body = pushNotification.getBody();
  print("Displaying notification: $body");

  if (kIsWeb) {
    // Use dart:js_interop to call the JavaScript function
    showWebNotification('Property ${pushNotification.propertyId} Update', body);
  } else {
    // Mobile: Use local notifications
    await localNotification.show(
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
