import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/change.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';

class PropertyNotification {
  final String id;
  final String propertyId;
  final int createdAt;
  final Map<FieldToSubscribe, Change> changes; // Keys are FieldCanChange enums
  final String? userId;
  final bool isRead;

  PropertyNotification({
    required this.id,
    required this.propertyId,
    required this.createdAt,
    required this.changes,
    this.userId,
    this.isRead = false,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true);

  factory PropertyNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null for ID: ${doc.id}');
    }
    final changesRaw = data['changes'] as Map<String, dynamic>? ?? {};
    final changes = changesRaw.map(
      (key, value) => MapEntry(
        // Convert string key to FieldCanChange enum
        FieldToSubscribe.values.firstWhere(
          (field) => field.name == key,
          orElse: () => throw FormatException('Unknown field: $key'),
        ),
        Change.fromMap(value as Map<String, dynamic>),
      ),
    );

    return PropertyNotification(
      id: doc.id,
      propertyId: data['propertyId'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      changes: changes,
      userId: data['userId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'propertyId': propertyId,
      'createdAt': createdAt,
      'changes': changes.map((key, value) => MapEntry(key.name, value.toMap())),
      if (userId != null) 'userId': userId,
      'isRead': isRead,
    };
  }

  static int _parseTimestamp(dynamic value) {
    if (value == null) {
      print('Warning: createdAt is null, using current time as fallback');
      return DateTime.now().millisecondsSinceEpoch;
    }
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    throw FormatException('Invalid timestamp format: $value');
  }

  @override
  String toString() {
    return 'PropertyNotification(id: $id, propertyId: $propertyId, createdAt: $createdAt, isRead: $isRead, userId: $userId)';
  }

  String changesToString() {
    if (changes.isEmpty) return 'No changes';
    return changes.entries
        .map((entry) => '${entry.key.name}: ${entry.value.toString()}')
        .join('\n');
  }
}
