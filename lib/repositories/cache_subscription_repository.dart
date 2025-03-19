import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/subscription.dart';

abstract class CacheSubscriptionRepository {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId);
}

class CacheSubscriptionRepositoryImpl implements CacheSubscriptionRepository {
  final FirebaseFirestore db;

  CacheSubscriptionRepositoryImpl({required this.db});

  @override
  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    try {
      final querySnapshot = await db
          .collection("subscriptions")
          .where("userId", isEqualTo: userId)
          .get(GetOptions(source: Source.cache));

      if (querySnapshot.docs.isEmpty) {
        print("No cached data found for userId: $userId");
        // Optional: Fallback to server if cache is empty
        // return await _fetchFromServer(userId);
      }

      final List<Subscription> result =
          querySnapshot.docs
              .map((doc) => Subscription.fromFirestore(doc.data(), doc.id))
              .toList();
      return result;
    } catch (e) {
      print("Error fetching subscriptions from cache: $e");
      return []; // Or rethrow the error depending on your needs
    }
  }

  @override
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId) async {
    try {
      final querySnapshot = await db
          .collection("subscriptions")
          .where("userId", isEqualTo: userId)
          .where("isSubscribed", isEqualTo: true)
          .get(GetOptions(source: Source.cache));

      if (querySnapshot.docs.isEmpty) {
        print("No active cached subscriptions found for userId: $userId");
      }

      final List<Subscription> result =
          querySnapshot.docs
              .map((doc) => Subscription.fromFirestore(doc.data(), doc.id))
              .toList();
      return result;
    } catch (e) {
      print("Error fetching active subscriptions from cache: $e");
      return [];
    }
  }
}
