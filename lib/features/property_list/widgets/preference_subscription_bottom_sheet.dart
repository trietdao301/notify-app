import 'package:flutter/material.dart';

class PreferenceSubscriptionBottomSheet extends StatelessWidget {
  final String parcelId;

  const PreferenceSubscriptionBottomSheet({super.key, required this.parcelId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Property Details: $parcelId',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text('Add your property details here...'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String parcelId) {
    showModalBottomSheet(
      context: context,
      builder:
          (BuildContext context) =>
              PreferenceSubscriptionBottomSheet(parcelId: parcelId),
    );
  }
}
