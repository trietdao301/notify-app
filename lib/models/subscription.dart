import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/enums/allow_notification_setting.dart';
import 'package:notifyapp/models/user_setting.dart';

// Enum for notification channels
enum NotificationChannel { email, sms, app }

class Subscription {
  String _documentId;
  String _userId;
  String _propertyId;
  bool _subscriptionStatus;
  Set<NotificationChannel> _notificationChannels;
  Set<FieldToSubscribe> _subscribedFields;

  // Constructor with validation
  Subscription({
    required String documentId,
    required String userId,
    required String propertyId,
    required bool subscriptionStatus,
    required Set<NotificationChannel> notificationChannels,
    required Set<FieldToSubscribe> subscribedFields,
  }) : _documentId = documentId,
       _userId = userId,
       _propertyId = propertyId,
       _subscriptionStatus = subscriptionStatus,
       _notificationChannels = notificationChannels,
       _subscribedFields = subscribedFields {
    if (documentId.isEmpty) throw Exception('Document ID cannot be empty');
    if (userId.isEmpty) throw Exception('User ID cannot be empty');
    if (propertyId.isEmpty) throw Exception('Property ID cannot be empty');
    if (notificationChannels.isEmpty) {
      throw Exception('At least one notification channel must be specified');
    }
    if (subscribedFields.isEmpty) {
      throw Exception('At least one alert preference must be specified');
    }
  }

  // Getters
  String get documentId => _documentId;
  String get userId => _userId;
  String get propertyId => _propertyId;
  bool get subscriptionStatus => _subscriptionStatus;
  Set<NotificationChannel> get notificationChannels => _notificationChannels;
  Set<FieldToSubscribe> get subscribedFields => _subscribedFields;

  // Setters
  set documentId(String value) => _documentId = value;
  set userId(String value) => _userId = value;
  set propertyId(String value) => _propertyId = value;
  set subscriptionStatus(bool value) => _subscriptionStatus = value;
  set notificationChannels(Set<NotificationChannel> value) =>
      _notificationChannels = value;
  set alertPreferences(Set<FieldToSubscribe> value) =>
      _subscribedFields = value;

  // Factory from JSON (e.g., for manual deserialization)
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      documentId: json['documentId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      subscriptionStatus: json['subscriptionStatus'] as bool? ?? false,
      notificationChannels:
          (json['notificationChannels'] as List<dynamic>? ?? [])
              .map(
                (e) => NotificationChannel.values.firstWhere(
                  (channel) => channel.name == e as String,
                  orElse: () => NotificationChannel.app, // Default fallback
                ),
              )
              .toSet(),
      subscribedFields:
          (json['subscribedFields'] as List<dynamic>? ?? [])
              .map(
                (e) => FieldToSubscribe.values.firstWhere(
                  (field) => field.name == e as String,
                  orElse: () => throw FormatException('Unknown field: $e'),
                ),
              )
              .toSet(),
    );
  }

  // Factory from Firestore
  factory Subscription.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Subscription(
      documentId: documentId,
      userId: data['userId'] as String? ?? '',
      propertyId: data['propertyId'] as String? ?? '',
      subscriptionStatus: data['subscriptionStatus'] as bool? ?? false,

      notificationChannels:
          (data['notificationChannels'] as List<dynamic>? ?? [])
              .map(
                (e) => NotificationChannel.values.firstWhere(
                  (channel) => channel.name == e as String,
                  orElse: () => NotificationChannel.app,
                ),
              )
              .toSet(),
      subscribedFields:
          (data['subscribedFields'] as List<dynamic>? ?? [])
              .map(
                (e) => FieldToSubscribe.values.firstWhere(
                  (field) => field.name == e as String,
                  orElse: () => throw FormatException('Unknown field: $e'),
                ),
              )
              .toSet(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': _userId,
      'propertyId': _propertyId,
      'subscriptionStatus': _subscriptionStatus,
      'notificationChannels':
          _notificationChannels.map((channel) => channel.name).toList(),
      'subscribedFields': _subscribedFields.map((field) => field.name).toList(),
    };
  }

  static UserSetting _defaultUserSetting() {
    return UserSetting();
  }
}
