import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';

// Enum for notification channels
enum NotificationChannel { email, sms, app }

class Subscription {
  String _documentId;
  String _userId;
  String _propertyId;
  bool _isSubscribed;
  Set<NotificationChannel> _notificationChannels;
  Set<FieldToSubscribe> _alertPreferences;

  Subscription({
    required String documentId,
    required String userId,
    required String propertyId,
    required bool isSubscribed,
    required Set<NotificationChannel> notificationChannels,
    required Set<FieldToSubscribe> alertPreferences,
  }) : _documentId = documentId,
       _userId = userId,
       _propertyId = propertyId,
       _isSubscribed = isSubscribed,
       _notificationChannels = notificationChannels,
       _alertPreferences = alertPreferences;

  // Getters
  String get documentId => _documentId;
  String get userId => _userId;
  String get propertyId => _propertyId;
  bool get isSubscribed => _isSubscribed;
  Set<NotificationChannel> get notificationChannels => _notificationChannels;
  Set<FieldToSubscribe> get alertPreferences => _alertPreferences;

  // Setters
  set documentId(String value) => _documentId = value;
  set userId(String value) => _userId = value;
  set propertyId(String value) => _propertyId = value;
  set isSubscribed(bool value) => _isSubscribed = value;
  set notificationChannels(Set<NotificationChannel> value) =>
      _notificationChannels = value;
  set alertPreferences(Set<FieldToSubscribe> value) =>
      _alertPreferences = value;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      documentId: json['documentId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      notificationChannels:
          (json['notificationChannels'] as List<dynamic>? ?? [])
              .map(
                (e) => NotificationChannel.values.firstWhere(
                  (channel) => channel.name == e as String,
                  orElse: () => NotificationChannel.app,
                ),
              )
              .toSet(),
      alertPreferences:
          (json['alertPreferences'] as List<dynamic>? ?? [])
              .map(
                (e) => FieldToSubscribe.values.firstWhere(
                  (field) => field.name == e as String,
                  orElse: () => throw FormatException('Unknown field: $e'),
                ),
              )
              .toSet(),
    );
  }

  factory Subscription.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Subscription(
      documentId: documentId,
      userId: data['userId'] as String? ?? '',
      propertyId: data['propertyId'] as String? ?? '',
      isSubscribed: data['isSubscribed'] as bool? ?? false,
      notificationChannels:
          (data['notificationChannels'] as List<dynamic>? ?? [])
              .map(
                (e) => NotificationChannel.values.firstWhere(
                  (channel) => channel.name == e as String,
                  orElse: () => NotificationChannel.app,
                ),
              )
              .toSet(),
      alertPreferences:
          (data['alertPreferences'] as List<dynamic>? ?? [])
              .map(
                (e) => FieldToSubscribe.values.firstWhere(
                  (field) => field.name == e as String,
                  orElse: () => throw FormatException('Unknown field: $e'),
                ),
              )
              .toSet(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': _userId,
      'propertyId': _propertyId,
      'isSubscribed': _isSubscribed,
      'notificationChannels':
          _notificationChannels.map((channel) => channel.name).toList(),
      'alertPreferences': _alertPreferences.map((field) => field.name).toList(),
    };
  }
}
