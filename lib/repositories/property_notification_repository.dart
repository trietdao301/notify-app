import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/property_notification.dart';

abstract class PropertyNotificationRepository {
  Future<List<PropertyNotification>> getNotificationsByUser({
    int skip = 0,
    required String userId,
  }); //skip  = property per page * page
}

class PropertyNotificationRepositoryImpl
    extends PropertyNotificationRepository {
  final FirebaseFirestore db;

  PropertyNotificationRepositoryImpl({required this.db});

  @override
  Future<List<PropertyNotification>> getNotificationsByUser({
    int skip = 0,
    required String userId,
  }) async {
    final querySnapshot =
        await db
            .collection('property_notifications')
            .where("userId", isEqualTo: userId)
            .where("isRead", isEqualTo: false)
            .get();

    return querySnapshot.docs
        .map((doc) => PropertyNotification.fromFirestore(doc))
        .toList();
  }
}
