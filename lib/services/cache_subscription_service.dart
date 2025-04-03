import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/repositories/cache_subscription_repository.dart';
import 'package:notifyapp/models/subscription.dart';

abstract class CacheSubscriptionService {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId);
  Future<Subscription?> getCacheSubscriptionByPropertyId(String propertyId);
}

class CacheSubscriptionServiceImp implements CacheSubscriptionService {
  final CacheSubscriptionRepository cacheSubscriptionRepository;
  final FirebaseAuth auth;
  CacheSubscriptionServiceImp({
    required this.cacheSubscriptionRepository,
    required this.auth,
  });

  @override
  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    List<Subscription> result = await cacheSubscriptionRepository
        .getSubscriptionsByUser(userId);
    return result;
  }

  @override
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId) async {
    List<Subscription> result = await cacheSubscriptionRepository
        .getActiveSubscriptionsByUser(userId);
    return result;
  }

  @override
  Future<Subscription?> getCacheSubscriptionByPropertyId(
    String propertyId,
  ) async {
    if (auth.currentUser == null) {
      throw Exception("User is null");
    }
    Subscription? result = await cacheSubscriptionRepository
        .getCacheSubscriptionByPropertyId(propertyId, auth.currentUser!.uid);

    return result;
  }
}
