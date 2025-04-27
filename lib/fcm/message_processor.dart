import 'dart:convert';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ignore_for_file: avoid_print
class MessageProcessor {
  static Map<FieldToSubscribe, Change> processMessage(
    String propertyId,
    RemoteMessage message,
  ) {
    try {
      Map<FieldToSubscribe, Change> result = {};

      for (var entry in message.data.entries) {
        if (entry.key == 'property_id') continue;
        if (entry.key == 'title') continue;
        final field = FieldToSubscribe.fromString(entry.key);
        Map<String, dynamic> payloadMap = _reformatPayload(entry.value);
        Change change = Change.fromMap(payloadMap);
        result[field] = change;
      }

      return result;
    } catch (e) {
      print("Error in processMessage: $e");
      return {};
    }
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
