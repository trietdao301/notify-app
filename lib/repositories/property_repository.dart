import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/property.dart';

abstract class PropertyRepository {
  Future<List<Property>> fetchProperties({
    int skip = 0,
  }); //skip  = property per page * page
}

class PropertyRepositoryImpl implements PropertyRepository {
  final FirebaseFirestore db;

  PropertyRepositoryImpl({required this.db});

  @override
  Future<List<Property>> fetchProperties({int skip = 0}) async {
    final querySnapshot = await db.collection('properties').get();
    try {
      return querySnapshot.docs
          .map((doc) => Property.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error in fetchProperties");
      throw Exception(e);
    }
  }
}
