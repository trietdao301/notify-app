import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  bool _isLoading = true;
  OverlayEntry? _notificationOverlay; // To manage the notification

  @override
  void initState() {
    super.initState();
    _loadInitialSubscriptionState();
  }

  Future<void> _loadInitialSubscriptionState() async {
    try {
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notificationOverlay?.remove(); // Clean up overlay on dispose
    super.dispose();
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
    setState(() {
      _isSubscribed = newValue;
    });

    _updateSubscription(newValue).catchError((e) {
      setState(() {
        _isSubscribed = !newValue;
      });
      print('Error in subscription change: $e');
      _showNotification(errorMessage: 'Error: $e');
    });
  }

  Future<void> _updateSubscription(bool newValue) async {
    final notifier = ref.read(subscriptionProvider.notifier);

    if (newValue) {
      await notifier.subscribeToProperty(
        widget.property.parcelId,
        NotificationChannel.app,
        {AlertEvent.ownership, AlertEvent.pricing, AlertEvent.tax},
      );
      _showNotification(
        successMessage: 'Subscribed to ${widget.property.parcelId}',
        undoAction: () => _onSubscriptionChanged(false),
      );
    } else {
      await notifier.unSubscribeToProperty(
        widget.property.parcelId,
        NotificationChannel.app,
        null,
      );
      _showNotification(
        successMessage: 'Unsubscribed from ${widget.property.parcelId}',
        undoAction: () => _onSubscriptionChanged(true),
      );
    }
    ref.invalidate(subscriptionProvider);
  }

  void _showNotification({
    String? successMessage,
    String? errorMessage,
    VoidCallback? undoAction,
  }) {
    // Remove any existing notification
    _notificationOverlay?.remove();

    // Create the new notification
    _notificationOverlay = OverlayEntry(
      builder:
          (context) => Positioned(
            top:
                MediaQuery.of(context).padding.top +
                16, // Account for status bar
            right: 16,
            width: 300, // Fixed width for consistency
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      errorMessage != null
                          ? Colors.grey[300]!.withOpacity(0.9)
                          : Colors.grey[200]!.withOpacity(0.9),
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        errorMessage ?? successMessage!,
                        style: TextStyle(
                          color: Colors.grey[900],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (undoAction != null)
                      TextButton(
                        onPressed: () {
                          undoAction();
                          _notificationOverlay?.remove();
                          _notificationOverlay = null;
                        },
                        child: Text(
                          'Undo',
                          style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
    );

    // Insert the notification into the overlay
    Overlay.of(context).insert(_notificationOverlay!);

    // Auto-dismiss after a delay
    Future.delayed(Duration(seconds: errorMessage != null ? 4 : 3), () {
      if (mounted) {
        _notificationOverlay?.remove();
        _notificationOverlay = null;
      }
    });
  }
}
