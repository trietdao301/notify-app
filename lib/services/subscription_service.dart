import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/repositories/subscription_repository.dart';
import 'package:notifyapp/services/fcm_subscription_service.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/subscription.dart';

abstract class SubscriptionService {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<void> subscribeToProperty(
    String propertyId,
    NotificationChannel channelToAdd,
    Set<FieldToSubscribe> alertsToAdd,
  );
  Future<void> unSubscribeToProperty(
    String propertyId,
    NotificationChannel channelToRemove,
    Set<FieldToSubscribe> alertToRemove,
  );
}

class SubscriptionServiceImp implements SubscriptionService {
  final FirebaseAuth auth;
  final SubscriptionRepository subscriptionRepository;
  final FcmSubscribeService fcmSubscribeService;

  SubscriptionServiceImp({
    required this.auth,
    required this.subscriptionRepository,
    required this.fcmSubscribeService,
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
    NotificationChannel channelToAdd,
    Set<FieldToSubscribe> preferenceToAdd,
  ) async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final documentId = '${userId}_$propertyId';
      try {
        await fcmSubscribeService.subscribeToPropertyTopic(propertyId);
        print('Subscribed to property ID: $documentId');
        await subscriptionRepository.saveSubscription(
          documentId,
          userId,
          propertyId,
          channelToAdd,
          preferenceToAdd,
          true,
        );
      } catch (e) {
        throw Exception("Fail to update subscription or fail to unsubscribe");
      }
    } else {
      throw Exception("Current user is null");
    }
  }

  @override
  Future<void> unSubscribeToProperty(
    String propertyId,
    NotificationChannel channelToRemove,
    Set<FieldToSubscribe> preferenceToRemove,
  ) async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final documentId = '${userId}_$propertyId';
      try {
        await subscriptionRepository.saveSubscription(
          documentId,
          userId,
          propertyId,
          channelToRemove,
          preferenceToRemove,
          false,
        );
        await fcmSubscribeService.unsubscribeFromPropertyTopic(propertyId);
        print('Unsubscribed to property ID: $documentId');
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Current user is null");
    }
  }
}
