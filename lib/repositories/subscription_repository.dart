import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<void> saveSubscription(
    String documentId,
    String userId,
    String propertyId,
    NotificationChannel channelToAdd,
    Set<FieldCanChange> alertsToAdd,
    bool isSubscribing,
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
    String documentId,
    String userId,
    String propertyId,
    NotificationChannel channels,
    Set<FieldCanChange> alerts,
    bool isSubscribing,
  ) async {
    final alertNames = alerts.map((alert) => alert.name).toList();
    if (isSubscribing) {
      await db.collection('subscriptions').doc(documentId).set({
        'userId': userId,
        'propertyId': propertyId,
        'isSubscribed': true,
        'notificationChannels': FieldValue.arrayUnion([channels.name]),
        'alertPreferences': FieldValue.arrayUnion(alertNames),
      }, SetOptions(merge: true));
    } else if (!isSubscribing) {
      await db.collection('subscriptions').doc(documentId).set({
        'userId': userId,
        'propertyId': propertyId,
        'isSubscribed': false,
        'notificationChannels': FieldValue.arrayRemove([channels.name]),
        'alertPreferences':
            alerts == {} ? null : FieldValue.arrayRemove(alertNames),
      }, SetOptions(merge: true));
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
