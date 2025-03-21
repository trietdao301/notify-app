import 'dart:convert';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ignore_for_file: avoid_print
class MessageProcessor {
  static Future<Map<FieldToSubscribe, Change>> processMessage(
    String propertyId,
    RemoteMessage message,
    Subscription subscription,
  ) async {
    try {
      if (subscription.alertPreferences.isEmpty) {
        throw Exception("Subscription does not have alert setting");
      }
      bool isAllFieldSubscription = subscription.alertPreferences.contains(
        FieldToSubscribe.all,
      );
      Map<FieldToSubscribe, Change> result;
      Map<FieldToSubscribe, Change> changes = filterProcessing(
        isAllFieldSubscription ? true : false,
        message.data,
        subscription,
      );
      result = changes;

      return result;
    } catch (e) {
      print("Error in processMessage: $e");
      return {};
    }
  }

  static Map<FieldToSubscribe, Change> filterProcessing(
    bool isAllFieldSubscription,
    Map<String, dynamic> messageData,
    Subscription subscription,
  ) {
    Map<FieldToSubscribe, Change> changes = {};
    if (isAllFieldSubscription) {
      for (var entry in messageData.entries) {
        if (entry.key == 'propertyId') continue;
        final field = FieldToSubscribe.fromString(entry.key);
        Map<String, dynamic> payloadMap = _reformatPayload(entry.value);
        Change change = Change.fromMap(payloadMap);
        changes[field] = change;
      }
    } else if (!isAllFieldSubscription) {
      for (var entry in messageData.entries) {
        if (entry.key == 'propertyId') continue;
        final field = FieldToSubscribe.fromString(entry.key);

        if (!subscription.alertPreferences.contains(field)) continue;

        Map<String, dynamic> payloadMap = _reformatPayload(entry.value);
        Change change = Change.fromMap(payloadMap);
        changes[field] = change;
      }
    }
    return changes;
  }

  static Map<String, dynamic> _reformatPayload(dynamic value) {
    try {
      String jsonString = value
          .toString()
          .replaceAll("'", '"')
          .replaceAll('True', 'true')
          .replaceAll('False', 'false');
      print("Fixed JSON string: $jsonString");
      Map<String, dynamic> payloadMap = json.decode(jsonString);
      return payloadMap;
    } catch (e) {
      throw Exception("Error in reformatPayload: $e");
    }
  }
}
