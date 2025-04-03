import 'package:notifyapp/exceptions/InvalidSelectedTimeException.dart';
import 'package:notifyapp/models/enums/day.dart';
import 'package:notifyapp/models/enums/allow_notification_setting.dart';
import 'package:notifyapp/models/enums/time_since_midnight.dart';

class UserSetting {
  final AllowNotificationSetting notificationSetting;
  final ReceiveWindow commonWindow;
  final Map<Day, ReceiveWindow> customWindows;
  final Frequency frequency;

  UserSetting({
    this.notificationSetting = AllowNotificationSetting.everyday,
    ReceiveWindow? commonWindow,
    Map<Day, ReceiveWindow>? customWindows,
    this.frequency = const Frequency(frequencyInMinute: 0),
  }) : customWindows = customWindows ?? _defaultCustomWindows(),
       commonWindow = commonWindow ?? defaultCommonWindow();

  factory UserSetting.fromJson(Map<String, dynamic> json) {
    return UserSetting(
      notificationSetting: AllowNotificationSetting.fromString(
        json['notificationSetting'] as String,
      ),
      commonWindow: ReceiveWindow.fromJson(
        json['commonWindow'] as Map<String, dynamic>,
      ),
      customWindows:
          json['customWindows'] != null
              ? (json['customWindows'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  Day.values.firstWhere(
                    (d) => d.name == key,
                    orElse: () => throw FormatException('Unknown day: $key'),
                  ),
                  ReceiveWindow.fromJson(value as Map<String, dynamic>),
                ),
              )
              : {},
      frequency:
          json['frequency'] != null
              ? Frequency.fromInteger(
                json['frequency']['frequencyInMinute'] as int,
              )
              : const Frequency(frequencyInMinute: 0),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'notificationSetting': notificationSetting.name,
    'commonWindow': commonWindow.toFirestore(),
    'customWindows': customWindows.map(
      (day, window) => MapEntry(day.name, window.toFirestore()),
    ),
    'frequency': {'frequencyInMinute': frequency.frequencyInMinute},
  };

  // Helper to get the effective window for a given day
  ReceiveWindow? getWindowForDay(Day day) {
    switch (notificationSetting) {
      case AllowNotificationSetting.everyday:
        return commonWindow;
      case AllowNotificationSetting.weekdays:
        if (day == Day.saturday || day == Day.sunday) {
          return null; // No notifications on weekends
        }
        return commonWindow;
      case AllowNotificationSetting.custom:
        return customWindows[day];
    }
  }

  // Static method to create the default customWindows map
  static Map<Day, ReceiveWindow> _defaultCustomWindows() {
    final defaultWindow = ReceiveWindow(
      start: DayMinute(minute: 8 * 60), // 8 AM (480 minutes)
      end: DayMinute(minute: 22 * 60), // 10 PM (1320 minutes)
    );
    return {for (var day in Day.values) day: defaultWindow};
  }

  static ReceiveWindow defaultCommonWindow() {
    return ReceiveWindow(
      start: DayMinute(minute: 8 * 60),
      end: DayMinute(minute: 22 * 60),
    );
  }
}

class ReceiveWindow {
  final DayMinute start;
  final DayMinute end;

  ReceiveWindow({required this.start, required this.end}) {
    if (start.minute >= end.minute) {
      final startTime =
          TimeSinceMidnight.fromMinuteSinceMidnight(start.minute).name;
      final endTime =
          TimeSinceMidnight.fromMinuteSinceMidnight(end.minute).name;
      throw InvalidSelectedTimeException(
        message: 'Start time ($startTime) must be before end time ($endTime).',
        startMinute: start.minute,
        endMinute: end.minute,
      );
    }
  }

  factory ReceiveWindow.fromJson(Map<String, dynamic> json) {
    return ReceiveWindow(
      start: DayMinute.fromInteger(json['start'] as int),
      end: DayMinute.fromInteger(json['end'] as int),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'start': start.minute,
    'end': end.minute,
  };
}

class DayMinute {
  final int minute;

  DayMinute({required this.minute}) {
    if (minute < 0 || minute >= (24 * 60)) {
      throw Exception("Invalid DayMinute: $minute");
    }
  }

  factory DayMinute.fromInteger(int input) {
    return DayMinute(minute: input);
  }
}

class Frequency {
  final int frequencyInMinute;

  const Frequency({required this.frequencyInMinute});

  factory Frequency.fromInteger(int frequencyInMinute) {
    if (frequencyInMinute < 0) {
      throw Exception("Invalid frequency in minute: $frequencyInMinute");
    }
    return Frequency(frequencyInMinute: frequencyInMinute);
  }
}
