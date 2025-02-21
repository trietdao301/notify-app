// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCFKAeQu3ZYTtyOQ0ZwrcUNxMTA8tRP5Uw",
  authDomain: "notification-app-123456.firebaseapp.com",
  projectId: "notification-app-123456",
  storageBucket: "notification-app-123456.firebasestorage.app",
  messagingSenderId: "210400931416",
  appId: "1:210400931416:web:6c936727c2ef9f694f642d"
});

const messaging = firebase.messaging();


  
// messaging.onBackgroundMessage((payload) => {
//   console.log("Received background message ", payload);
//   self.registration.showNotification(payload.notification.title, {
//       body: payload.notification.body,
//       icon: "/firebase-logo.png",
//   });
// });
