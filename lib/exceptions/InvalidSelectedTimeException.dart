class InvalidSelectedTimeException implements Exception {
  final String message;
  final int? startMinute; // Optional: Store the start time in minutes
  final int? endMinute; // Optional: Store the end time in minutes

  InvalidSelectedTimeException({
    required this.message,
    this.startMinute,
    this.endMinute,
  });

  @override
  String toString() {
    return message;
  }
}
