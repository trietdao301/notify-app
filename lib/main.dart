import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notifyapp/fcm/init.dart';
import 'package:notifyapp/models/user.dart';
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/router/router.dart';
import 'firebase_options.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final db = await initializeDb();

    await createAndSignInFirebaseAuth();
    final FirebaseMessagingService fcmService = FirebaseMessagingService();
    await fcmService.initialize();
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
  final String? fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken == null) return;
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

  //Step 3: Add or update the user in Firestore
  if (credential != null && credential.user != null) {
    final uid = credential.user!.uid;
    final userSetting = UserSetting();
    final Map<String, dynamic> data = {};

    data['isVerified'] = true;
    data['userSetting'] = userSetting.toFirestore();
    data['role'] = Role.admin.value;
    data['fcmTokens'] = FieldValue.arrayUnion([fcmToken]);
    data['lastReceived'] = 0;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
            data,
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
