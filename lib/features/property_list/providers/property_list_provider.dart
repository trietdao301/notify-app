import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifyapp/models/enums/field_to_subscribe.dart';
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/repositories/cache_subscription_repository.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:notifyapp/repositories/property_repository.dart';
import 'package:notifyapp/repositories/subscription_repository.dart';
import 'package:notifyapp/features/property_list/providers/propert_list_state.dart';
import 'package:notifyapp/global.dart';
import 'package:notifyapp/models/property.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/services/property_service.dart';
import 'package:notifyapp/services/subscription_service.dart';

class PropertyListScreenNotifier
    extends StateNotifier<PropertyListScreenState> {
  final PropertyService propertyService;
  final SubscriptionService subscriptionService;
  final CacheSubscriptionService cacheSubscriptionService;
  PropertyListScreenNotifier({
    required this.propertyService,
    required this.subscriptionService,
    required this.cacheSubscriptionService,
  }) : super(PropertyListScreenState());

  Future<void> fetchProperties() async {
    state = state.copyWith(
      state:
          state.page > 0
              ? PropertyListScreenConcreteState.fetchingMore
              : PropertyListScreenConcreteState.loading,
    );

    try {
      List<Property> result = await propertyService.getProperties(
        skip: state.page * PRODUCTS_PER_PAGE,
      );
      state = state.copyWith(
        state: PropertyListScreenConcreteState.fetchedAllProperties,
        propertyList: result,
        message: 'Fetching successfully',
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        state: PropertyListScreenConcreteState.error,
        message: 'Error message: ${e.toString()}',
      );
    }
  }

  Future<List<Subscription>> getSubscriptionsByUser(String userId) async {
    List<Subscription> result = await subscriptionService
        .getSubscriptionsByUser(userId);
    return result;
  }

  Future<void> subscribeToProperty(
    String propertyId,
    Set<NotificationChannel> channels,
    Set<FieldToSubscribe> fields,
    UserSetting userSetting,
  ) async {
    try {
      await subscriptionService.subscribeToProperty(
        propertyId,
        channels,
        fields,
        userSetting,
      );
    } catch (e) {
      state = state.copyWith(
        state: PropertyListScreenConcreteState.error,
        message: 'Error message: ${e.toString()}',
      );
    }
  }

  Future<void> unSubscribeToProperty(
    String propertyId,
    Set<NotificationChannel> channels,
    Set<FieldToSubscribe> fields,
    UserSetting userSetting,
  ) async {
    try {
      return await subscriptionService.unSubscribeToProperty(
        propertyId,
        channels,
        fields,
        userSetting,
      );
    } catch (e) {
      state = state.copyWith(
        state: PropertyListScreenConcreteState.error,
        message: 'Error message: ${e.toString()}',
      );
    }
  }

  Future<List<String>> getSubscribedPropertyIds(int skip) async {
    List<String> result = await propertyService.getSubscribedPropertyIds(
      skip: skip,
    );
    return result;
  }

  Future<Subscription?> getCurrentCachedSubscription(String propertyId) async {
    Subscription? subscription = await cacheSubscriptionService
        .getCacheSubscriptionByPropertyId(propertyId);

    return subscription;
  }
}

final propertyListScreenProvider =
    StateNotifierProvider<PropertyListScreenNotifier, PropertyListScreenState>((
      ref,
    ) {
      final fcm = FirebaseMessaging.instance;
      final firestore = FirebaseFirestore.instance; // Shared Firestore instance
      final auth = FirebaseAuth.instance;
      final PropertyRepository propertyRepository = PropertyRepositoryImpl(
        db: firestore,
      );
      final SubscriptionRepository subscriptionRepository =
          SubscriptionRepositoryImpl(db: firestore);

      final CacheSubscriptionRepository cacheSubscriptionRepository =
          CacheSubscriptionRepositoryImpl(db: firestore);
      final CacheSubscriptionService cacheSubscriptionService =
          CacheSubscriptionServiceImp(
            cacheSubscriptionRepository: cacheSubscriptionRepository,
            auth: auth,
          );

      final SubscriptionService subscriptionService = SubscriptionServiceImp(
        auth: auth,
        subscriptionRepository: subscriptionRepository,

        fcm: FirebaseMessaging.instance,
      );
      final PropertyService propertyService = PropertyServiceImpl(
        propertyRepository: propertyRepository,
        subscriptionService: subscriptionService,
        auth: auth,
      );

      return PropertyListScreenNotifier(
        propertyService: propertyService,
        subscriptionService: subscriptionService,
        cacheSubscriptionService: cacheSubscriptionService,
      )..fetchProperties();
    });
