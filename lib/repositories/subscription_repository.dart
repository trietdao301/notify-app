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
    bool subscriptionStatus,
  );
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId);
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
    bool subscriptionStatus,
  ) async {
    if (alerts == null) return;
    try {
      Subscription subscriptionToAdd = Subscription(
        documentId: subscriptionId,
        userId: userId,
        propertyId: propertyId,
        subscriptionStatus: subscriptionStatus,
        notificationChannels: channels ?? {},
        subscribedFields: alerts ?? {},
      );
      await db
          .collection('subscriptions')
          .doc(subscriptionId)
          .set(subscriptionToAdd.toFirestore(), SetOptions(merge: true));
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
}
