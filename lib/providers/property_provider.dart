import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifyapp/models/property.dart';

import 'package:riverpod/riverpod.dart';

class PropertyProvider extends AsyncNotifier<List<Property>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Future<List<Property>> build() async {
    final user = _auth.currentUser;
    print(user);
    if (user == null) {
      // Sign in anonymously if no user is logged in
      await _auth.signInAnonymously();
    }
    return getAllProperties();
  }

  Future<List<Property>> getAllProperties() async {
    final querySnapshot = await db.collection('properties').get();
    return querySnapshot.docs
        .map((doc) => Property.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}

final propertyProvider =
    AsyncNotifierProvider<PropertyProvider, List<Property>>(
      PropertyProvider.new,
    );
