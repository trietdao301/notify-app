import 'dart:convert';
import 'package:notifyapp/models/Change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/push_notification.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ignore_for_file: avoid_print
class MessageProcessor {
  static Map<String, dynamic> reformatPayload(dynamic value) {
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

  static Future<Map<FieldCanChange, Change>> processMessage(
    String propertyId,
    RemoteMessage message,
    Subscription subscription,
  ) async {
    try {
      print("Processing message for property: $propertyId");
      print("Subscription preferences: ${subscription.alertPreferences}");
      print("Message data: ${message.data}");

      Map<FieldCanChange, Change> changes = {};
      message.data.forEach((String key, dynamic value) {
        if (key == 'propertyId') return;

        final field = FieldCanChange.fromString(key);
        if (field != null && subscription.alertPreferences.contains(field)) {
          print("Processing field: $key");
          print("Raw value: $value");

          Map<String, dynamic> payloadMap = reformatPayload(value);
          print("Decoded map: $payloadMap");

          Change change = Change.fromMap(payloadMap);
          changes[field] = change;
        }
      });

      return changes;
    } catch (e) {
      print("Error in processMessage: $e");
      return {};
    }
  }
}
