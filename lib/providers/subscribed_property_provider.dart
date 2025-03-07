import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/providers/subscription_provider.dart';

class SubscribedPropertyProvider extends AsyncNotifier<List<String>> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Future<List<String>> build() async {
    print('SubscribedPropertyProvider build() started');

    // Directly await subscriptionProvider's data
    final subscriptions = await ref.watch(subscriptionProvider.future);
    print('Fetched subscriptions: $subscriptions');

    if (currentUser == null) {
      print("No authenticated user, returning empty subscription list");
      return [];
    }

    final subscribedPropertyIds =
        subscriptions
            .where((sub) => sub.userId == currentUser!.uid && sub.isSubscribed)
            .map((sub) => sub.propertyId)
            .toList();

    print('Filtered subscribedPropertyIds: $subscribedPropertyIds');
    return subscribedPropertyIds;
  }
}

final subscribedPropertyProvider =
    AsyncNotifierProvider<SubscribedPropertyProvider, List<String>>(
      SubscribedPropertyProvider.new,
    );
