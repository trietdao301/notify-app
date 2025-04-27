import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingWeb {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print(
      'Web notification authorization status: ${settings.authorizationStatus}',
    );
    getFCMToken();
  }

  Future getFCMToken({int maxRetires = 3}) async {
    try {
      String? token;
      if (kIsWeb) {
        print("getting token for web");
        String? cachedToken = await _firebaseMessaging.getToken();
        if (cachedToken != null) {
          print("cached web token: ${cachedToken}");
          return;
        }
        token = await _firebaseMessaging.getToken(
          vapidKey:
              "BOWSk929uln4Dso2LcxTYdo1O6gN3EjJ-MDlIDy2OhNVCyaksHKzgqebAbHePAjd3iEtM-fxCdFX5GLzO0kj998",
        );
        print("for web device token: $token");
      } else {
        throw Exception("Expect to be web, but got other platform.");
      }
      return token;
    } catch (e) {
      print("failed to get device token. Error: ${e.toString()}");
      if (maxRetires > 0) {
        print("try after 10 sec");
        await Future.delayed(Duration(seconds: 10));
        return getFCMToken(maxRetires: maxRetires - 1);
      } else {
        return null;
      }
    }
  }
}
