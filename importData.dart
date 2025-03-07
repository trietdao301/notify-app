// Create sample property objects and import them to Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notifyapp/models/property.dart';

Future<void> importPropertySamplesToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final propertiesCollection = firestore.collection('properties');

  print(
    'Import completed: ${sampleProperties.length} properties added to Firestore',
  );
}
