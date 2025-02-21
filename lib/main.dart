import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notifyapp/services/firebase_messaging_service.dart';

import 'firebase_options.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Text('Hello, Flutter!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
