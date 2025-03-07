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
  late bool _isSubscribed;
  bool _isLoading = true; // Track initial loading state

  @override
  void initState() {
    super.initState();

    _loadInitialSubscriptionState(); // Fetch provider data once
  }

  Future<void> _loadInitialSubscriptionState() async {
    try {
      // Fetch subscribedPropertyProvider data only once on app start
      final subscribedPropertyIds = await ref.read(
        subscribedPropertyProvider.future,
      );

      if (mounted) {
        setState(() {
          _isSubscribed = subscribedPropertyIds.contains(
            widget.property.parcelId.toString(),
          );

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading initial subscription state: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Show switch even on error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Switch.adaptive(
                      thumbIcon: widget.thumbIcon,
                      value: _isSubscribed,
                      onChanged: (newValue) => _onSubscriptionChanged(newValue),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSubscriptionChanged(bool newValue) {
    // Optimistically update UI immediately
    setState(() {
      _isSubscribed = newValue;
    });

    // Perform database operation asynchronously
    _updateSubscription(newValue).catchError((e) {
      // Revert UI on error
      setState(() {
        _isSubscribed = !newValue;
      });
      print('Error in subscription change: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update subscription: $e')),
      );
    });
  }

  Future<void> _updateSubscription(bool newValue) async {
    final notifier = ref.read(subscriptionProvider.notifier);
    final fcmService = ref.read(fcmServiceProvider);

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
      }
    } else {
      await notifier.unSubscribeToProperty(
        widget.property.parcelId,
        NotificationChannel.app,
        null,
      );
      if (!kIsWeb) {
        await fcmService.unsubscribeFromPropertyTopic(widget.property.parcelId);
      } else {
        print('FCM topic unsubscription skipped on web (configure if needed)');
      }
    }
    // Refresh provider for next app start
    ref.invalidate(subscriptionProvider);
  }
}
