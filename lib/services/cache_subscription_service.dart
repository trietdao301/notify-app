import 'package:notifyapp/repositories/cache_subscription_repository.dart';
import 'package:notifyapp/models/subscription.dart';

abstract class CacheSubscriptionService {
  Future<List<Subscription>> getSubscriptionsByUser(String userId);
  Future<List<Subscription>> getActiveSubscriptionsByUser(String userId);
}

class CacheSubscriptionServiceImp implements CacheSubscriptionService {
  final CacheSubscriptionRepository cacheSubscriptionRepository;

  CacheSubscriptionServiceImp({required this.cacheSubscriptionRepository});

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
}
