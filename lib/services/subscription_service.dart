import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/repositories/cache_subscription_repository.dart';
import 'package:notifyapp/repositories/subscription_repository.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/subscription.dart';

abstract class SubscriptionService {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<void> subscribeToProperty(
    String propertyId,
    Set<NotificationChannel> channels,
    Set<FieldToSubscribe> fields,
    UserSetting userSetting,
  );
  Future<void> unSubscribeToProperty(
    String propertyId,
    Set<NotificationChannel> channels,
    Set<FieldToSubscribe> fields,
    UserSetting userSetting,
  );

  Future<void> updateAllCurrentSubscriptionSetting(UserSetting userSetting);
}

class SubscriptionServiceImp implements SubscriptionService {
  final FirebaseAuth auth;
  final SubscriptionRepository subscriptionRepository;

  final FirebaseMessaging fcm;
  SubscriptionServiceImp({
    required this.auth,
    required this.subscriptionRepository,

    required this.fcm,
  });

  @override
  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    List<Subscription> result = await subscriptionRepository
        .getSubscriptionsByUser(userId);
    return result;
  }

  @override
  Future<void> subscribeToProperty(
    String propertyId,
    Set<NotificationChannel> channels,
    Set<FieldToSubscribe> fields,
    UserSetting userSetting,
  ) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("Current user is null when subscribing");
    }
    final userId = currentUser.uid;
    final subscriptionId = '${userId}_$propertyId';
    final String? fcmToken = await fcm.getToken();
    if (fcmToken == null) {
      throw Exception(
        "No fcm Token is found for this user when subscribeToProperty",
      );
    }
    subscriptionRepository.saveSubscription(
      subscriptionId,
      userId,
      propertyId,
      channels,
      fields,
      userSetting,
      true,
      fcmToken,
    );
  }

  @override
  Future<void> unSubscribeToProperty(
    String propertyId,
    Set<NotificationChannel> channels,
    Set<FieldToSubscribe> fields,
    UserSetting userSetting,
  ) async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final subscriptionId = '${userId}_$propertyId';
      final String? fcmToken = await fcm.getToken();
      if (fcmToken == null) {
        throw Exception(
          "No fcm Token is found for this user when subscribeToProperty",
        );
      }
      subscriptionRepository.saveSubscription(
        subscriptionId,
        userId,
        propertyId,
        channels,
        fields,
        userSetting,
        false,
        fcmToken,
      );
    }
  }

  @override
  Future<void> updateAllCurrentSubscriptionSetting(
    UserSetting userSetting,
  ) async {
    print("YES OK");

    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      print("User settting: ${userSetting.toString()}");
      await subscriptionRepository.updateAllCurrentSubscriptionSetting(
        userId,
        userSetting,
      );
      return;
    }
  }
}
