import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/models/user_setting.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<void> saveSubscription(
    String subscriptionId,
    String userId,
    String propertyId,
    Set<NotificationChannel>? channels,
    Set<FieldToSubscribe>? alerts,
    UserSetting userSetting,
    bool subscriptionStatus,
    String fcmToken,
  );
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId);
  Future<void> updateAllCurrentSubscriptionSetting(
    String userId,
    UserSetting userSetting,
  );
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final FirebaseFirestore db;
  SubscriptionRepositoryImpl({required this.db});

  @override
  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    final querySnapshot =
        await db
            .collection("subscriptions")
            .where("userId", isEqualTo: userId)
            .get();
    final List<Subscription> result =
        querySnapshot.docs
            .map((doc) => Subscription.fromFirestore(doc.data(), doc.id))
            .toList();
    return result;
  }

  @override
  Future<void> saveSubscription(
    String subscriptionId,
    String userId,
    String propertyId,
    Set<NotificationChannel>? channels,
    Set<FieldToSubscribe>? alerts,
    UserSetting userSetting,
    bool subscriptionStatus,
    String fcmToken,
  ) async {
    final alertNames = alerts!.map((alert) => alert.name).toList();
    final channelNames =
        channels?.map((channel) => channel.name).toList() ?? [];

    try {
      await db.collection('subscriptions').doc(subscriptionId).set({
        'userId': userId,
        'propertyId': propertyId,
        'subscriptionStatus': subscriptionStatus,
        'notificationChannels': channelNames,
        'userSetting': userSetting.toFirestore(),
        if (subscriptionStatus) 'fcmToken': FieldValue.arrayUnion([fcmToken]),
        'alertPreferences':
            alerts.contains(FieldToSubscribe.all)
                ? [FieldToSubscribe.all.name]
                : alertNames,
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      print(stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId) async {
    final querySnapshot =
        await db
            .collection("subscriptions")
            .where("userId", isEqualTo: userId)
            .where("isSubscribed", isEqualTo: true)
            .get();
    final List<Subscription> result =
        querySnapshot.docs
            .map((doc) => Subscription.fromFirestore(doc.data(), doc.id))
            .toList();
    return result;
  }

  @override
  Future<void> updateAllCurrentSubscriptionSetting(
    String userId,
    UserSetting userSetting,
  ) async {
    final querySnapshot =
        await db
            .collection("subscriptions")
            .where("userId", isEqualTo: userId)
            .where("subscriptionStatus", isEqualTo: true)
            .get();
    final batch = db.batch();

    for (var doc in querySnapshot.docs) {
      batch.update(db.collection('subscriptions').doc(doc.id), {
        'userSetting': userSetting.toFirestore(),
      });
    }
    await batch.commit();
  }
}
