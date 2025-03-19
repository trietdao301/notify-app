import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:notifyapp/repositories/property_notification_repository.dart';
import 'package:notifyapp/models/enums/field_can_change.dart';
import 'package:riverpod/riverpod.dart';
import 'package:notifyapp/repositories/property_repository.dart';
import 'package:notifyapp/repositories/subscription_repository.dart';
import 'package:notifyapp/fcm_service/fcm_subscribe_service.dart';
import 'package:notifyapp/features/property_list/providers/propert_list_state.dart';
import 'package:notifyapp/global.dart';
import 'package:notifyapp/models/property.dart';
import 'package:notifyapp/models/subscription.dart';
import 'package:notifyapp/services/property_service.dart';
import 'package:notifyapp/services/subscription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyListScreenNotifier
    extends StateNotifier<PropertyListScreenState> {
  final PropertyService propertyService;
  final SubscriptionService subscriptionService;

  PropertyListScreenNotifier({
    required this.propertyService,
    required this.subscriptionService,
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
    NotificationChannel channelToAdd,
    Set<FieldCanChange> alertsToAdd,
  ) async {
    return subscriptionService.subscribeToProperty(
      propertyId,
      channelToAdd,
      alertsToAdd,
    );
  }

  Future<void> unSubscribeToProperty(
    String propertyId,
    NotificationChannel channelToRemove,
    FieldCanChange? alertToRemove,
  ) async {
    return subscriptionService.unSubscribeToProperty(
      propertyId,
      channelToRemove,
      alertToRemove != null ? {alertToRemove} : {},
    );
  }

  Future<List<String>> getSubscribedPropertyIds(int skip) async {
    List<String> result = await propertyService.getSubscribedPropertyIds(
      skip: skip,
    );
    return result;
  }
}

final propertyListScreenProvider =
    StateNotifierProvider<PropertyListScreenNotifier, PropertyListScreenState>((
      ref,
    ) {
      final fcm = FirebaseMessaging.instance;
      final fcmSubscribeService = FcmSubscribeServiceImpl(messaging: fcm);
      final firestore = FirebaseFirestore.instance; // Shared Firestore instance
      final auth = FirebaseAuth.instance;
      final PropertyRepository propertyRepository = PropertyRepositoryImpl(
        db: firestore,
      );
      final SubscriptionRepository subscriptionRepository =
          SubscriptionRepositoryImpl(db: firestore);

      final SubscriptionService subscriptionService = SubscriptionServiceImp(
        auth: auth,
        subscriptionRepository: subscriptionRepository,
        fcmSubscribeService: fcmSubscribeService,
      );
      final PropertyService propertyService = PropertyServiceImpl(
        propertyRepository: propertyRepository,
        subscriptionService: subscriptionService,
        auth: auth,
      );

      return PropertyListScreenNotifier(
        propertyService: propertyService,
        subscriptionService: subscriptionService,
      )..fetchProperties();
    });
