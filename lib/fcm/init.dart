import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notifyapp/fcm/platforms/android.dart';
import 'package:notifyapp/fcm/platforms/ios.dart';
import 'package:notifyapp/fcm/platforms/web.dart';

import 'package:notifyapp/services/cache_subscription_service.dart';

// ignore_for_file: avoid_print, constant_identifier_names
class FirebaseMessagingService {
  FirebaseMessagingService();

  Future<void> initialize() async {
    if (kIsWeb) {
      await FirebaseMessagingWeb().initialize();
    } else if (Platform.isAndroid) {
      await FirebaseMessagingAndroid().initialize();
    } else if (Platform.isIOS) {
      await FirebaseMessagingIOS().initialize();
    }
  }

  void handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
  }
}
