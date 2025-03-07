import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enum for notification channels
enum NotificationChannel { email, sms, app }

// Enum for alert event categories
enum AlertEvent { pricing, tax, ownership }

class Subscription {
  final String documentId;
  final String userId;
  final String propertyId;
  final bool isSubscribed;
  final Set<NotificationChannel> notificationPrefs;
  final Set<AlertEvent> alertEvents;

  Subscription({
    required this.documentId,
    required this.userId,
    required this.propertyId,
    required this.isSubscribed,
    required this.notificationPrefs,
    required this.alertEvents,
  });

  factory Subscription.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Subscription(
      documentId: documentId,
      userId: data['userId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      isSubscribed: data['isSubscribed'] ?? false,
      notificationPrefs:
          (data['notificationPrefs'] as List<dynamic>? ?? [])
              .map(
                (e) => NotificationChannel.values.firstWhere(
                  (channel) => channel.name == e,
                  orElse: () => NotificationChannel.app,
                ),
              )
              .toSet(),
      alertEvents:
          (data['alertEvents'] as List<dynamic>? ?? [])
              .map(
                (e) => AlertEvent.values.firstWhere(
                  (event) => event.name == e,
                  orElse: () => AlertEvent.pricing,
                ),
              )
              .toSet(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'propertyId': propertyId,
      'isSubscribed': isSubscribed,
      'notificationPrefs':
          notificationPrefs.map((channel) => channel.name).toList(),
      'alertEvents': alertEvents.map((event) => event.name).toList(),
    };
  }
}
