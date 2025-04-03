import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/repositories/property_repository.dart';
import 'package:notifyapp/models/property.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/services/subscription_service.dart';

abstract class PropertyService {
  Future<List<Property>> getProperties({required int skip});
  Future<List<String>> getSubscribedPropertyIds({required int skip});
}

class PropertyServiceImpl implements PropertyService {
  final FirebaseAuth auth;
  final PropertyRepository propertyRepository;
  final SubscriptionService subscriptionService;
  PropertyServiceImpl({
    required this.propertyRepository,
    required this.auth,
    required this.subscriptionService,
  });

  @override
  Future<List<Property>> getProperties({required int skip}) async {
    if (auth.currentUser == null) {
      throw Exception("Not logged in");
    }
    return propertyRepository.fetchProperties(skip: skip);
  }

  @override
  Future<List<String>> getSubscribedPropertyIds({required int skip}) async {
    User? currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception("Current user is null");
    }
    List<Subscription> subscriptions = await subscriptionService
        .getSubscriptionsByUser(currentUser.uid);
    final subscribedPropertyIds =
        subscriptions
            .where(
              (sub) => sub.userId == currentUser.uid && sub.subscriptionStatus,
            )
            .map((sub) => sub.propertyId)
            .toList();
    return subscribedPropertyIds;
  }
}
