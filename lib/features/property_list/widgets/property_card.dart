import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/property_list/providers/property_list_provider.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/models/property.dart';
import 'package:notifyapp/features/property_list/widgets/property_info.dart';
import 'package:toastification/toastification.dart';

class PropertyCard extends ConsumerStatefulWidget {
  PropertyCard({super.key, required this.property});

  final Property property;
  final WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty<Icon>.fromMap(<WidgetStatesConstraint, Icon>{
        WidgetState.selected: const Icon(Icons.check),
        WidgetState.any: const Icon(Icons.close),
      });

  @override
  ConsumerState<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<PropertyCard> {
  late bool _isSubscribed;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialSubscriptionState();
  }

  Future<void> _loadInitialSubscriptionState() async {
    try {
      final subscribedPropertyIds = await ref
          .read(propertyListScreenProvider.notifier)
          .getSubscribedPropertyIds(0);
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
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: const Text('Error'),
          description: Text('Failed to load: $e'),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(milliseconds: 3500), // ~3.5s
          backgroundColor: Color(0xFFFFFFFF), // White background
          foregroundColor: Colors.grey[900], // Dark text for readability
          borderRadius: BorderRadius.circular(4.0),
          applyBlurEffect: true,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: Colors.grey.shade300, // Subtle grey border
          width: 1, // Tiny border width
        ),
      ),
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
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text('Error'),
        description: Text('Error: $e'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(milliseconds: 3500), // ~3.5s
        backgroundColor: Color(0xFFFFFFFF), // White background
        foregroundColor: Colors.grey[900], // Dark text for readability
        borderRadius: BorderRadius.circular(4.0),
        applyBlurEffect: true,
      );
    });
  }

  Future<void> _updateSubscription(bool newValue) async {
    final notifier = ref.read(propertyListScreenProvider.notifier);

    if (newValue) {
      await notifier.subscribeToProperty(
        widget.property.parcelId,
        NotificationChannel.app,
        {FieldCanChange.book, FieldCanChange.editFlag},
      );

      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text('Subscribed to ${widget.property.parcelId}'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        backgroundColor: Color(0xFFFFFFFF), // White background
        foregroundColor: Colors.grey[900], // Dark text for readability
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ), // Green checkmark
        borderRadius: BorderRadius.circular(4.0),
        applyBlurEffect: true,
      );
    } else {
      await notifier.unSubscribeToProperty(
        widget.property.parcelId,
        NotificationChannel.app,
        null,
      );

      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.flat,
        title: Text('Unsubscribed from ${widget.property.parcelId}'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        backgroundColor: Color(0xFFFFFFFF), // White background
        foregroundColor: Colors.grey[900], // Dark text for readability
        borderRadius: BorderRadius.circular(4.0),
        applyBlurEffect: true,
      );
    }
  }
}
