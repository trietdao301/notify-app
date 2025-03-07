import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/models/property.dart';
import 'package:notifyapp/providers/fcm_provider.dart';
import 'package:notifyapp/providers/subscribed_property_provider.dart';
import 'package:notifyapp/providers/subscription_provider.dart';
import 'package:notifyapp/screens/home_screen/property_info.dart';

class PropertyCard extends ConsumerStatefulWidget {
  PropertyCard({super.key, required this.property});

  bool isSubscribed = false; // Kept as in your original, though unused
  final Property property;
  final WidgetStateProperty<Icon> thumbIcon = WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.check),
      WidgetState.any: Icon(Icons.close),
    },
  );
  @override
  ConsumerState<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<PropertyCard> {
  @override
  Widget build(BuildContext context) {
    final subscribedPropertyIdsProvider = ref.watch(subscribedPropertyProvider);
    final List<String>? subscribedPropertyIds =
        subscribedPropertyIdsProvider.value;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Todo
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PropertyInfo(widget: widget),
                Switch.adaptive(
                  thumbIcon: widget.thumbIcon,
                  value:
                      subscribedPropertyIds != null
                          ? subscribedPropertyIds.contains(
                            widget.property.parcelId,
                          )
                          : false,
                  onChanged: (newValue) => _onSubscriptionChanged(newValue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSubscriptionChanged(bool newValue) async {
    final notifier = ref.read(subscriptionProvider.notifier);
    final fcmService = ref.read(fcmServiceProvider);

    try {
      if (newValue) {
        await notifier.subscribeToProperty(
          widget.property.parcelId,
          NotificationChannel.app,
          {AlertEvent.ownership, AlertEvent.pricing, AlertEvent.tax},
        );

        if (!kIsWeb) {
          await fcmService.subscribeToPropertyTopic(widget.property.parcelId);
        } else {
          print('FCM topic subscription skipped on web (configure if needed)');
          // Optionally add web-specific logic here
        }
      } else {
        // Unsubscribe from property in Firestore (all platforms)
        await notifier.unSubscribeToProperty(
          widget.property.parcelId,
          NotificationChannel.app,
          null,
        );
        // Unsubscribe from FCM topic (non-web only, or web if configured)
        if (!kIsWeb) {
          await fcmService.unsubscribeFromPropertyTopic(
            widget.property.parcelId,
          );
        } else {
          print(
            'FCM topic unsubscription skipped on web (configure if needed)',
          );
          // Optionally add web-specific logic here
        }
      }
      ref.invalidate(subscriptionProvider);
    } catch (e) {
      print('Error in subscription change: $e');
    }
  }
}
