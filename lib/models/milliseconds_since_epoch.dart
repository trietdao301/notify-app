class MillisecondsSinceEpoch {
  int milliseconds;
  MillisecondsSinceEpoch({required this.milliseconds});

  DateTime toUtcDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }
}
