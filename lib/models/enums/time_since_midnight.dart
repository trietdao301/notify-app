// Enum for time intervals
import 'package:intl/intl.dart';

enum TimeSinceMidnight {
  t1200AM("12:00 AM"),
  t1230AM("12:30 AM"),
  t100AM("1:00 AM"),
  t130AM("1:30 AM"),
  t200AM("2:00 AM"),
  t230AM("2:30 AM"),
  t300AM("3:00 AM"),
  t330AM("3:30 AM"),
  t400AM("4:00 AM"),
  t430AM("4:30 AM"),
  t500AM("5:00 AM"),
  t530AM("5:30 AM"),
  t600AM("6:00 AM"),
  t630AM("6:30 AM"),
  t700AM("7:00 AM"),
  t730AM("7:30 AM"),
  t800AM("8:00 AM"),
  t830AM("8:30 AM"),
  t900AM("9:00 AM"),
  t930AM("9:30 AM"),
  t1000AM("10:00 AM"),
  t1030AM("10:30 AM"),
  t1100AM("11:00 AM"),
  t1130AM("11:30 AM"),
  t1200PM("12:00 PM"),
  t1230PM("12:30 PM"),
  t100PM("1:00 PM"),
  t130PM("1:30 PM"),
  t200PM("2:00 PM"),
  t230PM("2:30 PM"),
  t300PM("3:00 PM"),
  t330PM("3:30 PM"),
  t400PM("4:00 PM"),
  t430PM("4:30 PM"),
  t500PM("5:00 PM"),
  t530PM("5:30 PM"),
  t600PM("6:00 PM"),
  t630PM("6:30 PM"),
  t700PM("7:00 PM"),
  t730PM("7:30 PM"),
  t800PM("8:00 PM"),
  t830PM("8:30 PM"),
  t900PM("9:00 PM"),
  t930PM("9:30 PM"),
  t1000PM("10:00 PM"),
  t1030PM("10:30 PM"),
  t1100PM("11:00 PM"),
  t1130PM("11:30 PM");

  final String name;
  const TimeSinceMidnight(this.name);

  // Helper to get all values as a list of strings
  static List<String> get allNames =>
      TimeSinceMidnight.values.map((e) => e.name).toList();

  // Helper to find enum from string
  static TimeSinceMidnight fromString(String time) {
    return TimeSinceMidnight.values.firstWhere(
      (e) => e.name == time,
      orElse: () => throw Exception("Invalid time interval: '$time'"),
    );
  }

  static TimeSinceMidnight fromMinuteSinceMidnight(int minuteSinceMidnight) {
    if (minuteSinceMidnight < 0 || minuteSinceMidnight >= 24 * 60) {
      throw Exception(
        "Minutes must be between 0 and 1439: $minuteSinceMidnight",
      );
    }
    int intervals = (minuteSinceMidnight / 30).floor();
    return TimeSinceMidnight.values[intervals];
  }

  int get minutesSinceMidnight {
    return TimeSinceMidnight.values.indexOf(this) * 30;
  }

  static List<String> getEndIntervalList(TimeSinceMidnight startTime) {
    final startIndex = TimeSinceMidnight.values.indexOf(startTime);

    final List<TimeSinceMidnight> allIntervals = TimeSinceMidnight.values;
    final List<String> combinedStartAndEndList = [
      ...allIntervals.sublist(startIndex).map((e) => e.name),
      ...allIntervals.sublist(0, startIndex).map((e) => e.name),
    ];
    return combinedStartAndEndList;
  }

  static int toMinutesSinceMidnight(TimeSinceMidnight time) {
    final DateFormat formatter = DateFormat('h:mm a');
    try {
      final parsedTime = formatter.parse(time.name);
      return parsedTime.hour * 60 + parsedTime.minute;
    } catch (e) {
      throw Exception("Error in TimeProcessor, in toMinutesSinceMidnight: $e");
    }
  }
}
