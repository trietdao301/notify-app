import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/models/subscription.dart';

class NotificationSubscriptionProvider
    extends AsyncNotifier<List<Subscription>> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Future<List<Subscription>> build() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      return getSubscriptionsByUser(currentUser.uid);
    }
    print("current user is null, so subscription list is empty");
    return [];
  }

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

  Future<void> subscribeToProperty(
    String propertyId,
    NotificationChannel channelToAdd,
    Set<AlertEvent> alertsToAdd,
  ) async {
    final currentUser = auth.currentUser;

    if (currentUser != null) {
      final userId = currentUser.uid;
      final documentId = '${userId}_$propertyId';

      try {
        final alertNames = alertsToAdd.map((alert) => alert.name).toList();
        await db.collection('subscriptions').doc(documentId).set({
          'userId': userId,
          'propertyId': propertyId,
          'isSubscribed': true,
          'notificationPrefs': FieldValue.arrayUnion([channelToAdd.name]),
          'alertEvents': FieldValue.arrayUnion(alertNames),
        }, SetOptions(merge: true));
        print(
          'Subscribed to property ID: $documentId with '
          'channel: ${channelToAdd.name}, alert: ${alertsToAdd}',
        );
      } catch (e) {
        print('Error subscribing to property: $e');
      }
    } else {
      print('No authenticated user found');
    }
  }

  Future<void> unSubscribeToProperty(
    String propertyId,
    NotificationChannel channelToRemove,
    AlertEvent? alertToRemove,
  ) async {
    final currentUser = auth.currentUser;

    if (currentUser != null) {
      final userId = currentUser.uid;
      final documentId = '${userId}_$propertyId';

      try {
        await db.collection('subscriptions').doc(documentId).set({
          'userId': userId,
          'propertyId': propertyId,
          'isSubscribed': false,
          'notificationPrefs': FieldValue.arrayRemove([channelToRemove.name]),
          'alertEvents':
              alertToRemove != null
                  ? FieldValue.arrayRemove([alertToRemove.name])
                  : null,
        }, SetOptions(merge: true));
        print(
          'Unsubscribed to property ID: $documentId with '
          'removing channel: ${channelToRemove.name}, removing alert: ${alertToRemove != null ? alertToRemove.name : 'None'}',
        );
      } catch (e) {
        print('Error unsubscribing to property: $e');
      }
    } else {
      print('No authenticated user found');
    }
  }
}

final subscriptionProvider =
    AsyncNotifierProvider<NotificationSubscriptionProvider, List<Subscription>>(
      NotificationSubscriptionProvider.new,
    );
