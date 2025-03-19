// Enum to define change types
enum ChangeType { updated, added, removed }

// Class to represent a single field change
class Change {
  final ChangeType type;
  final dynamic oldValue; // Null for additions
  final dynamic newValue; // Null for removals

  Change({required this.type, this.oldValue, this.newValue});

  factory Change.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String;
    return Change(
      type: ChangeType.values.firstWhere((t) => t.name == typeStr),
      oldValue: map['oldValue'],
      newValue: map['newValue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      if (oldValue != null) 'oldValue': oldValue,
      if (newValue != null) 'newValue': newValue,
    };
  }

  @override
  String toString() {
    switch (type) {
      case ChangeType.updated:
        return 'Updated from $oldValue to $newValue';
      case ChangeType.added:
        return 'Added: $newValue';
      case ChangeType.removed:
        return 'Removed: $oldValue';
    }
  }
}
