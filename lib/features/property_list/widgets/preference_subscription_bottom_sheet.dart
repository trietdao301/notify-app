import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/property_list/providers/property_list_provider.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/models/user.dart' as UserModel;
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/shared/providers/current_user_provider.dart';

class PreferenceSubscriptionBottomSheet extends ConsumerStatefulWidget {
  final String propertyId;
  final Function()? onUnsubscribe;

  const PreferenceSubscriptionBottomSheet({
    required this.propertyId,
    this.onUnsubscribe, // Optional callback
  });

  @override
  ConsumerState<PreferenceSubscriptionBottomSheet> createState() =>
      _PreferenceSubscriptionBottomSheetState();

  static void show(
    BuildContext context,
    String propertyId, {
    Function()? onUnsubscribe,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (BuildContext context) => PreferenceSubscriptionBottomSheet(
            propertyId: propertyId,
            onUnsubscribe: onUnsubscribe,
          ),
    );
  }
}

class _PreferenceSubscriptionBottomSheetState
    extends ConsumerState<PreferenceSubscriptionBottomSheet> {
  Set<FieldToSubscribe> chosenFields = {};
  Set<FieldToSubscribe> originalChosenField = {};
  bool _isLoading = true;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadSubscription();
  }

  Future<void> loadSubscription() async {
    final currentSubscription = await ref
        .read(propertyListScreenProvider.notifier)
        .getCurrentCachedSubscription(widget.propertyId);
    print(currentSubscription);
    if (mounted) {
      setState(() {
        chosenFields = currentSubscription!.alertPreferences.toSet();
        originalChosenField = currentSubscription!.alertPreferences.toSet();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 300,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Property Details: ${widget.propertyId}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(FieldToSubscribe.values.length, (
                  index,
                ) {
                  final currentField = FieldToSubscribe.values[index];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : Checkbox(
                            checkColor: Colors.white,
                            value:
                                chosenFields.contains(currentField) ||
                                chosenFields.contains(FieldToSubscribe.all),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (currentField == FieldToSubscribe.all) {
                                    chosenFields.clear();
                                    chosenFields.add(FieldToSubscribe.all);
                                  } else {
                                    chosenFields.add(currentField);
                                  }
                                } else {
                                  if (currentField == FieldToSubscribe.all) {
                                    chosenFields.clear();
                                  } else {
                                    chosenFields.remove(currentField);
                                  }
                                }
                              });
                            },
                          ),
                      Text(
                        currentField.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                setEquals(chosenFields, originalChosenField)
                    ? null
                    : () => onSave(ref, widget.propertyId, chosenFields),

            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> onSave(
    WidgetRef ref,
    String propertyId,
    Set<FieldToSubscribe> chosenFields,
  ) async {
    Navigator.pop(context); // Close the bottom sheet first

    final notifier = ref.read(propertyListScreenProvider.notifier);
    final currentUserState = ref.read(currentUserProvider);
    if (currentUserState.currentUser == null) {
      return;
    }
    if (chosenFields.isEmpty) {
      // Unsubscribe if no fields are selected
      await notifier.unSubscribeToProperty(
        propertyId,
        {},
        chosenFields,
        currentUserState.currentUser!.userSetting,
      );
      if (widget.onUnsubscribe != null) {
        widget.onUnsubscribe!();
      }
    } else {
      // Subscribe with selected fields
      await notifier.subscribeToProperty(
        propertyId,
        {NotificationChannel.app},
        chosenFields,
        currentUserState.currentUser!.userSetting,
      );
    }
  }
}
