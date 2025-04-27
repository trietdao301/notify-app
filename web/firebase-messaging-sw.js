// firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Initialize Firebase app
const firebaseApp = firebase.initializeApp({
  apiKey: "AIzaSyCFKAeQu3ZYTtyOQ0ZwrcUNxMTA8tRP5Uw",
  authDomain: "notification-app-123456.firebaseapp.com",
  projectId: "notification-app-123456",
  storageBucket: "notification-app-123456.firebasestorage.app",
  messagingSenderId: "210400931416",
  appId: "1:210400931416:web:6c936727c2ef9f694f642d"
});

// Initialize messaging
const messaging = firebase.messaging(firebaseApp);

// // Handle background messages
// messaging.onBackgroundMessage(function(payload) {
//   console.log('[firebase-messaging-sw.js] Received background message:', payload);
  
//   // // Customize notification (optional)
//   // const notificationTitle = payload.notification?.title || 'Property Update';
//   // const notificationOptions = {
//   //   body: payload.notification?.body || 'A property has been updated.',
//   //   icon: '/favicon.png' // Ensure this exists in web/
//   // };

//   // self.registration.showNotification(notificationTitle, notificationOptions);
// });