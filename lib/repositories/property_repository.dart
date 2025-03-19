import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/repositories/property_repository.dart';
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
    return querySnapshot.docs
        .map((doc) => Property.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
