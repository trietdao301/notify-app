import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notifyapp/models/user.dart';
import 'package:notifyapp/screens/home_screen/home_screen.dart';
import 'package:notifyapp/services/firebase_messaging_service.dart';
import 'firebase_options.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/models/user.dart' as UserModel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");

    final messagingService = FirebaseMessagingService();
    await messagingService.initialize();
  } catch (error) {
    print("Firebase initialization failed: $error");
  }

  await createAndSignInFirebaseAuth();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RealPropertyApp(),
    );
  }
}

class RealPropertyApp extends StatelessWidget {
  const RealPropertyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Property Records Notification',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      // routes: {'/house_detail': (context) =>  HouseDetailScreen(house: null,)},
    );
  }
}

// Will be used for singup and signin in the future
Future<void> createAndSignInFirebaseAuth() async {
  UserCredential? credential;
  try {
    credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "triet.dao@wsu.edu",
      password: "warcraft301",
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }

  try {
    credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "triet.dao@wsu.edu",
      password: "warcraft301",
    );
    print("Sign in successfully");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
    print(e.code);
  }

  // Step 3: Add or update the user in Firestore
  if (credential != null && credential.user != null) {
    final uid = credential.user!.uid;
    final user = UserModel.User(
      isVerified: true,
      ownedProperty: [], // No properties owned yet
      role: Role.admin,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
            user.toFirestore(),
            SetOptions(merge: true), // Merge to avoid overwriting existing data
          );
      print('User $uid added to Firestore successfully');
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  } else {
    print('No valid user credential available to add to Firestore');
  }
}
