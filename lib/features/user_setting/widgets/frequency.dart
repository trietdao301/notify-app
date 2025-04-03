import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/user_setting/providers/user_setting_provider.dart';
import 'package:notifyapp/features/user_setting/widgets/custom_time_dialog.dart';
import 'package:notifyapp/models/user_setting.dart';

List<DropdownMenuEntry<String>> minutes = List.generate(
  48,
  (index) => DropdownMenuEntry<String>(
    label: "${index * 30} minutes",
    value: "${index * 30}",
  ),
);

class FrequencyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return FrequencyWidgetState();
  }
}

class FrequencyWidgetState extends ConsumerState<FrequencyWidget> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userSettingScreenProvider);
    final notifier = ref.read(userSettingScreenProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text("Frequency"),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTimeDialog(
                  initialSelection:
                      state.userSetting.frequency.frequencyInMinute.toString(),
                  onSelected: (String? value) {
                    if (value == null) return;
                    int frequencyInMinute;
                    try {
                      frequencyInMinute = int.parse(value);
                    } catch (e) {
                      throw Exception(
                        "Fail to convert String into Int in frequency selection",
                      );
                    }
                    notifier.updateSettingState(
                      frequency: Frequency(
                        frequencyInMinute: frequencyInMinute,
                      ),
                    );
                  },
                  items: minutes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
