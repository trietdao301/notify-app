enum AllowNotificationSetting {
  everyday("Every day"),
  weekdays("Weekdays"),
  custom("Custom");

  final String name;
  const AllowNotificationSetting(this.name);

  static AllowNotificationSetting fromString(String name) {
    return AllowNotificationSetting.values.firstWhere(
      (setting) => setting.name == name,
      orElse:
          () => throw FormatException('Unknown notification setting: $name'),
    );
  }
}
