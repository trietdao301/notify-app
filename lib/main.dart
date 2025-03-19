import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifyapp/models/user.dart';
import 'package:notifyapp/repositories/cache_subscription_repository.dart';
import 'package:notifyapp/router/router.dart';
import 'package:notifyapp/fcm_service/firebase_messaging_service.dart';
import 'package:notifyapp/services/cache_subscription_service.dart';
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
    final db = await initializeDb();
    await createAndSignInFirebaseAuth();
    final CacheSubscriptionRepository cacheSubscriptionRepository =
        CacheSubscriptionRepositoryImpl(db: db);
    final CacheSubscriptionService cacheSubscriptionService =
        CacheSubscriptionServiceImp(
          cacheSubscriptionRepository: cacheSubscriptionRepository,
        );

    final messagingService = FirebaseMessagingService(
      auth: FirebaseAuth.instance,
      cacheSubscriptionService: cacheSubscriptionService,
    );

    await messagingService.initialize();
  } catch (error) {
    print("Firebase initialization failed: $error");
  }

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: FToastBuilder(),
      title: 'Real Property Records Notification',
      routerConfig: router,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 249, 249, 249),
        appBarTheme: AppBarTheme(color: Colors.white),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
      ),
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

Future<FirebaseFirestore> initializeDb() async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  if (kIsWeb) {
    await db.enablePersistence(
      const PersistenceSettings(synchronizeTabs: true),
    );
  } else if (!kIsWeb) {
    db.settings = const Settings(persistenceEnabled: true);
  }
  db.settings = const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  return db;
}
