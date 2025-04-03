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
  Set<FieldToSubscribe> _alertPreferences;
  Set<String> _fcmToken;
  UserSetting _userSetting;

  // Constructor with validation
  Subscription({
    required String documentId,
    required String userId,
    required String propertyId,
    required bool subscriptionStatus,
    required Set<NotificationChannel> notificationChannels,
    required Set<FieldToSubscribe> alertPreferences,
    required Set<String> fcmToken,
    required UserSetting userSetting,
  }) : _documentId = documentId,
       _userId = userId,
       _propertyId = propertyId,
       _subscriptionStatus = subscriptionStatus,
       _notificationChannels = notificationChannels,
       _alertPreferences = alertPreferences,
       _fcmToken = fcmToken,
       _userSetting = userSetting {
    if (documentId.isEmpty) throw Exception('Document ID cannot be empty');
    if (userId.isEmpty) throw Exception('User ID cannot be empty');
    if (propertyId.isEmpty) throw Exception('Property ID cannot be empty');
    if (fcmToken.isEmpty) throw Exception('FCM token cannot be empty');
    if (notificationChannels.isEmpty) {
      throw Exception('At least one notification channel must be specified');
    }
    if (alertPreferences.isEmpty) {
      throw Exception('At least one alert preference must be specified');
    }
  }

  // Getters
  String get documentId => _documentId;
  String get userId => _userId;
  String get propertyId => _propertyId;
  bool get subscriptionStatus => _subscriptionStatus;
  Set<NotificationChannel> get notificationChannels => _notificationChannels;
  Set<FieldToSubscribe> get alertPreferences => _alertPreferences;
  Set<String> get fcmToken => _fcmToken;
  UserSetting get userSetting => _userSetting;

  // Setters
  set documentId(String value) => _documentId = value;
  set userId(String value) => _userId = value;
  set propertyId(String value) => _propertyId = value;
  set subscriptionStatus(bool value) => _subscriptionStatus = value;
  set notificationChannels(Set<NotificationChannel> value) =>
      _notificationChannels = value;
  set alertPreferences(Set<FieldToSubscribe> value) =>
      _alertPreferences = value;
  set fcmToken(Set<String> value) => _fcmToken = value;
  set userSetting(UserSetting value) => _userSetting = value;

  // Factory from JSON (e.g., for manual deserialization)
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      documentId: json['documentId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      subscriptionStatus: json['subscriptionStatus'] as bool? ?? false,
      fcmToken: json['fcmToken'] as Set<String>? ?? {},
      notificationChannels:
          (json['notificationChannels'] as List<dynamic>? ?? [])
              .map(
                (e) => NotificationChannel.values.firstWhere(
                  (channel) => channel.name == e as String,
                  orElse: () => NotificationChannel.app, // Default fallback
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
      userSetting:
          json['userSetting'] != null
              ? UserSetting.fromJson(
                json['userSetting'] as Map<String, dynamic>,
              )
              : _defaultUserSetting(),
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
      fcmToken:
          (data['fcmToken'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          <String>{},
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
      userSetting:
          data['userSetting'] != null
              ? UserSetting.fromJson(
                data['userSetting'] as Map<String, dynamic>,
              )
              : _defaultUserSetting(), // Provide default if null
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
      'alertPreferences': _alertPreferences.map((field) => field.name).toList(),
      'fcmToken': _fcmToken,
      'userSetting': _userSetting.toFirestore(),
    };
  }

  static UserSetting _defaultUserSetting() {
    return UserSetting();
  }
}
