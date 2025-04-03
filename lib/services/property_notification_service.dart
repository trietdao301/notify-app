import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/repositories/property_notification_repository.dart';
import 'package:notifyapp/models/property_notification.dart';

abstract class PropertyNotificationService {
  Future<List<PropertyNotification>> getNotificationsByUser({
    int skip = 0,
    required String userId,
  });
}

class PropertyNotificationServiceImpl implements PropertyNotificationService {
  final FirebaseAuth auth;
  final PropertyNotificationRepository propertyNotificationRepository;
  PropertyNotificationServiceImpl({
    required this.auth,
    required this.propertyNotificationRepository,
  });

  @override
  Future<List<PropertyNotification>> getNotificationsByUser({
    int skip = 0,
    required String userId,
  }) async {
    if (auth.currentUser == null) {
      throw Exception("Not logged in");
    }
    return await propertyNotificationRepository.getNotificationsByUser(
      skip: skip,
      userId: userId,
    );
  }
}
