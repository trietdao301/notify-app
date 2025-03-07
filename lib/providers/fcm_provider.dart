import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// FCM Service Provider
final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> subscribeToPropertyTopic(String propertyId) async {
    final topic = 'property_$propertyId';
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to FCM topic: $topic');
    } catch (e) {
      print('Error subscribing to FCM topic: $e');
      rethrow; // Propagate error for handling upstream
    }
  }

  Future<void> unsubscribeFromPropertyTopic(String propertyId) async {
    final topic = 'property_$propertyId';
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from FCM topic: $topic');
    } catch (e) {
      print('Error unsubscribing from FCM topic: $e');
      rethrow;
    }
  }
}
