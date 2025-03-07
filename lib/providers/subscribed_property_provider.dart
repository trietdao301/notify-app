import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/providers/subscription_provider.dart';

class SubscribedPropertyProvider extends AsyncNotifier<List<String>> {
  final currentUser = FirebaseAuth.instance.currentUser;

  // Provide a List subscribed property Id by current user in String
  @override
  Future<List<String>> build() async {
    final _subscriptionProvider = ref.watch(subscriptionProvider);

    final List<Subscription> subscriptions = await _subscriptionProvider.when(
      data: (subs) => subs, // List<Subscription>
      loading:
          () => Future.value(<Subscription>[]), // Explicitly List<Subscription>
      error: (error, stack) => throw error, // Propagates error
    );

    if (currentUser == null) {
      print("No authenticated user, returning empty subscription list");
      return [];
    }

    // Filter subscriptions for the current user where isSubscribed is true
    final subscribedPropertyIds =
        subscriptions
            .where((sub) => sub.userId == currentUser!.uid && sub.isSubscribed)
            .map((sub) => sub.propertyId)
            .toList();

    return subscribedPropertyIds;
  }
}

final subscribedPropertyProvider =
    AsyncNotifierProvider<SubscribedPropertyProvider, List<String>>(
      SubscribedPropertyProvider.new,
    );
