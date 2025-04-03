import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/user_setting/providers/user_setting_provider.dart';
import 'package:notifyapp/features/user_setting/providers/user_setting_state.dart';
import 'package:notifyapp/features/user_setting/widgets/custom_time_dialog.dart';
import 'package:notifyapp/features/user_setting/widgets/frequency.dart';
import 'package:notifyapp/models/enums/allow_notification_setting.dart';
import 'package:notifyapp/models/enums/day.dart';
import 'package:notifyapp/models/enums/time_since_midnight.dart';
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/shared/providers/current_user_provider.dart';

final Map<int, String> timeToNameMap = {
  for (var time in TimeSinceMidnight.values)
    time.minutesSinceMidnight: time.name,
};

final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
  AllowNotificationSetting.values
      .map<MenuEntry>(
        (AllowNotificationSetting setting) =>
            MenuEntry(value: setting.name, label: setting.name),
      )
      .toList(),
);

final List<MenuEntry> allTimes = UnmodifiableListView<MenuEntry>(
  TimeSinceMidnight.values
      .map<MenuEntry>(
        (TimeSinceMidnight setting) =>
            MenuEntry(value: setting.name, label: setting.name),
      )
      .toList(),
);

class UserSettingScreen extends ConsumerStatefulWidget {
  UserSettingScreen({super.key});

  @override
  ConsumerState<UserSettingScreen> createState() => _UserSettingScreenState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _UserSettingScreenState extends ConsumerState<UserSettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveSettings() async {
    try {
      final notifier = ref.read(userSettingScreenProvider.notifier);
      await notifier.saveSetting();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving settings: $e")));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Build started: ${DateTime.now()}");
    final state = ref.watch(userSettingScreenProvider);
    final notifier = ref.read(userSettingScreenProvider.notifier);
    if (state.state == UserSettingConcreteState.invalidSelectedTimeError &&
        state.message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.orange, // Use orange to indicate a warning
          ),
        );
        // Reset the state to fetchedSetting to avoid repeated warnings
        notifier.updateSettingState();
      });
    }

    final widgetTree = Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "User Setting",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(state.message, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                if (state.state == UserSettingConcreteState.initial)
                  const Center(child: LinearProgressIndicator()),
                if (state.state == UserSettingConcreteState.loading)
                  const Center(child: CircularProgressIndicator()),
                if (state.state == UserSettingConcreteState.error)
                  const Center(child: Icon(Icons.error_outline)),
                if (state.state == UserSettingConcreteState.fetchedSetting) ...[
                  const Text(
                    "Notification schedule",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "You'll only receive notifications in the hours you choose. Outside of those times, notifications will be paused. Learn more",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Allow notifications:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      DropdownMenu<String>(
                        initialSelection:
                            state.userSetting.notificationSetting.name,
                        onSelected: (String? value) {
                          if (value == null) return;
                          notifier.updateSettingState(
                            notificationSetting:
                                AllowNotificationSetting.fromString(value),
                          );
                        },
                        dropdownMenuEntries: menuEntries,
                        width: 150,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.userSetting.notificationSetting ==
                          AllowNotificationSetting.everyday ||
                      state.userSetting.notificationSetting ==
                          AllowNotificationSetting.weekdays)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTimeDialog(
                          initialSelection: _getInitialSelection(
                            state.userSetting.commonWindow.start.minute,
                          ),
                          onSelected: (String? value) {
                            if (value == null) return;
                            int startTimeSinceMidNightInInteger =
                                TimeSinceMidnight.fromString(
                                  value,
                                ).minutesSinceMidnight;
                            notifier.updateSettingState(
                              commonWindow: ReceiveWindow(
                                start: DayMinute(
                                  minute: startTimeSinceMidNightInInteger,
                                ),
                                end: state.userSetting.commonWindow.end,
                              ),
                            );
                          },
                          items: allTimes,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("to"),
                        ),
                        CustomTimeDialog(
                          initialSelection: _getInitialSelection(
                            state.userSetting.commonWindow.end.minute,
                            isEnd: true,
                          ),
                          onSelected: (String? value) {
                            if (value == null) return;
                            int endTimeSinceMidNightInInteger =
                                TimeSinceMidnight.fromString(
                                  value,
                                ).minutesSinceMidnight;
                            notifier.updateSettingState(
                              commonWindow: ReceiveWindow(
                                start: state.userSetting.commonWindow.start,
                                end: DayMinute(
                                  minute: endTimeSinceMidNightInInteger,
                                ),
                              ),
                            );
                          },
                          items: allTimes,
                        ),
                      ],
                    ),
                  if (state.userSetting.notificationSetting ==
                      AllowNotificationSetting.weekdays)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "You won't receive notifications on Saturday or Sunday.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  if (state.userSetting.notificationSetting ==
                      AllowNotificationSetting.custom)
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children:
                          Day.values.map((day) {
                            final window =
                                state.userSetting.customWindows[day] ??
                                ReceiveWindow(
                                  start: DayMinute(minute: 0),
                                  end: DayMinute(minute: 1410),
                                );
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 100, child: Text(day.name)),
                                  CustomTimeDialog(
                                    initialSelection: _getInitialSelection(
                                      window.start.minute,
                                    ),
                                    onSelected: (String? value) {
                                      if (value == null) return;
                                      int startTimeSinceMidNightInInteger =
                                          TimeSinceMidnight.fromString(
                                            value,
                                          ).minutesSinceMidnight;
                                      final updatedWindows =
                                          Map<Day, ReceiveWindow>.from(
                                            state.userSetting.customWindows,
                                          );
                                      updatedWindows[day] = ReceiveWindow(
                                        start: DayMinute(
                                          minute:
                                              startTimeSinceMidNightInInteger,
                                        ),
                                        end: window.end,
                                      );
                                      notifier.updateSettingState(
                                        customWindows: updatedWindows,
                                      );
                                    },
                                    items: allTimes,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text("to"),
                                  ),
                                  CustomTimeDialog(
                                    initialSelection: _getInitialSelection(
                                      window.end.minute,
                                      isEnd: true,
                                    ),
                                    onSelected: (String? value) {
                                      if (value == null) return;
                                      int endTimeSinceMidNightInInteger =
                                          TimeSinceMidnight.fromString(
                                            value,
                                          ).minutesSinceMidnight;
                                      final updatedWindows =
                                          Map<Day, ReceiveWindow>.from(
                                            state.userSetting.customWindows,
                                          );
                                      updatedWindows[day] = ReceiveWindow(
                                        start: window.start,
                                        end: DayMinute(
                                          minute: endTimeSinceMidNightInInteger,
                                        ),
                                      );
                                      notifier.updateSettingState(
                                        customWindows: updatedWindows,
                                      );
                                    },
                                    items: allTimes,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 24),
                  FrequencyWidget(),
                  Center(
                    child:
                        state.isSaved
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                              onPressed: _saveSettings,
                              child: const Text("Save"),
                            ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    print("Build completed: ${DateTime.now()}");
    return widgetTree;
  }

  String _getInitialSelection(int? minute, {bool isEnd = false}) {
    if (minute == null) {
      return isEnd ? timeToNameMap[1410]! : timeToNameMap[0]!;
    }
    return timeToNameMap.containsKey(minute)
        ? timeToNameMap[minute]!
        : (isEnd ? timeToNameMap[1410]! : timeToNameMap[0]!);
  }
}
