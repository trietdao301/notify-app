import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notifyapp/fcm_service/helpers/message_processor.dart';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/push_notification.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/repositories/cache_subscription_repository.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';

// ignore_for_file: avoid_print, constant_identifier_names
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    print("Background message received: ${message.messageId}");
    print("Message data: ${message.data}");
    String propertyId = message.data["propertyId"];
    if (kIsWeb) {
      print("Background handler skipped - web platform not supported");
      return;
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    final cacheSubscriptionRepository = CacheSubscriptionRepositoryImpl(
      db: FirebaseFirestore.instance,
    );
    final cacheSubscriptionService = CacheSubscriptionServiceImp(
      cacheSubscriptionRepository: cacheSubscriptionRepository,
    );
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

    List<Subscription> activeSubscriptions = await cacheSubscriptionService
        .getActiveSubscriptionsByUser(auth.currentUser!.uid);
    Subscription subscription = activeSubscriptions.firstWhere(
      (each) => each.propertyId == propertyId,
      orElse:
          () =>
              throw Exception('No subscription found for property $propertyId'),
    );

    Map<FieldToSubscribe, Change> changes =
        await MessageProcessor.processMessage(
          propertyId,
          message,
          subscription,
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
