import 'dart:convert';
import 'package:notifyapp/models/Change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';

class PushNotification {
  final String propertyId;
  final Map<FieldCanChange, Change> changes;

  PushNotification({required this.propertyId, required this.changes});

  @override
  String toString() =>
      'PropertyChange(propertyId: $propertyId, changes: $changes)';

  String getBody() {
    if (changes.isEmpty) {
      throw Exception("Changes is empty in notification of ${propertyId}");
    }
    List<String> body = [];
    changes.forEach((FieldCanChange key, Change value) {
      if (value.type == ChangeType.added) {
        body.add("${key.name}: ${value.type} ${value.newValue}");
      } else if (value.type == ChangeType.removed) {
        body.add("${key.name}: ${value.type} ${value.newValue}");
      } else if (value.type == ChangeType.updated) {
        body.add(
          "${key.name}: ${value.type.name} from ${value.newValue} to ${value.oldValue}",
        );
      }
    });
    return body.join('\n');
  }

  factory PushNotification.fromMapString(Map<String, String> input) {
    final propertyId = input['propertyId'];
    if (propertyId == null || propertyId.isEmpty) {
      throw FormatException('Missing or empty propertyId in input map');
    }

    final changes = <FieldCanChange, Change>{};

    // Process all entries except propertyId
    input.forEach((key, value) {
      if (key != 'propertyId') {
        try {
          final field = FieldCanChange.values.firstWhere(
            (f) => f.name == key,
            orElse: () => throw FormatException('Unknown field: $key'),
          );

          // Decode the JSON string into a Map and create Change object
          final changeMap = json.decode(value) as Map<String, dynamic>;
          changes[field] = Change.fromMap(changeMap);
        } catch (e) {
          print('Error processing field $key: $e');
        }
      }
    });

    if (changes.isEmpty) {
      throw FormatException('No valid changes found in input map');
    }

    return PushNotification(propertyId: propertyId, changes: changes);
  }
}
