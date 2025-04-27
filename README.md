# Intro

This is a setup for a notification system for Android and Web, while IOS is not support because of Apple developer charge. 

Notification types are push with FCM and in-app notifications with stream provider. 

There are 4 main features:
1. In-app notification
2. Field-based subscription 
3. Push notification
4. Schedule notifications based on customizable windows and frequency

# Setup

Firebase:
1. run ```npm install -g firebase-tools```
2. run ```firebase login```
3. run ```firebase init ```
4. run ```firebase projects:create your-project-name```
5. Choose Android, IOS and Web apps for firebase project, this will create a ```firebase_options.dart``` in lib folder 

Firebase Cloud Messaging:
1. Open Firebase Console -> Project Setting -> Cloud Messaging -> Scroll down to the bottom and create a key pair ![alt text](<Screenshot 2025-04-27 at 6.25.57 AM.png>)
2. lib -> fcm -> platforms -> web.dart, and replace validKey in getFCMToken() with the created key pair. 

Database:
1. Open Firebase Console and register a firestore database as usual. 
2. Open Rules and copy/paste this code in.  
```rust
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /properties/{propertyId} {
      allow read: if request.auth != null;  // Allow anyone to read properties
      allow write: if request.auth != null;  // Require auth for writes
    }
    
    match /users/{userId}{ // This userId is from FirebaseAuth
    	allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /subscriptions/{subscriptionId}{
    	allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /property_notifications/{notificationId}{
    	allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /scheduled_notifications/{notificationId}{
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

Firebase Authentication:
1. Open Firebase Console -> build -> Authentication
2. Open Sign-in method Tab -> Add new Provider -> Choose Email/Password
3. In Project -> lib -> main.dart -> line 60 -> replace email and password with new ones. 
4. In Project -> lib -> main.dart -> line 75 -> replace email and password with new ones. 

# Features walk through 
Features:
1. In-app Notification:
    - lib -> shared -> providers -> notification_stream_provider.dart (this is a stream provider that listens to changes from firestore)
    - The notificationStreamProvider will return ```List<PropertyNotification>```
        ```dart
        @override
        Stream<List<PropertyNotification>> build() {
            final user = auth.currentUser;
            if (user == null) {
            return Stream.value([]);
            }

            return FirebaseFirestore.instance
                .collection('property_notifications')
                .where('userId', isEqualTo: user.uid)
                .where('isRead', isEqualTo: false)
                .snapshots()
                .map(
                (snapshot) =>
                    snapshot.docs
                        .map((doc) => PropertyNotification.fromFirestore(doc))
                        .toList(),
                );
        }
        ```
    - Example of using (line 43 notification_stream_provider.dart):
        ```dart
        final notifications = ref.watch(notificationStreamProvider);
        return notifications.when(
            data: (notificationList) => notificationList.length,
            loading: () => 0,
            error: (_, __) => 0,
        );
        ```
2. Field-based subscription:
    - Most logics stay on cloud function, as cloud function will query user setting to see if the field is selected for specific user and decide if the user needs to be notified. 
    - The goal in app side is only to add subscribed fields to firestore. 
3. Push notification:
    - All push notification logics stay in lib -> fcm folder.
    - Cloud function will use fcm to send notification as "data" instead of "notification". [For more info](https://firebase.google.com/docs/cloud-messaging/concept-options#:~:text=Use%20notification%20messages%20when%20you,including%20an%20optional%20data%20payload.)
    - The App will receive "data" and use local notification to display notification if mobile, while use JavaScript to display web notification if web.
    - If use Mobile, Web and app is in foreground, ```handleForegroundMessage()``` will be triggered. 
    - If use Mobile and app is in background, ```firebaseMessagingBackgroundHandler()``` will trigger
    - If use Web, app is in background, ```..lib/web/firebase-messaging-sw.js``` will run. 
    - To customize push notification for Android, lib -> fcm -> helpers -> displayNotification.dart, modify local notification show method.
        ```dart
            await localNotification.show(
            pushNotification.hashCode,
            'Property ${pushNotification.propertyId} Update',
            body,
            NotificationDetails(
                android: const AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                importance: Importance.max,
                priority: Priority.max,
                color: Color(0xFF607D8B),
                styleInformation: DefaultStyleInformation(true, true),
                ),
            ),
            );
        ``` 
    - To customize web notification, modify ```../lib/web/show_web_notification.js```

4. Schedule notifications based on customizable windows and frequency
    - Most logics stay on cloud function side. 
    - Our app only needs to add correct data like window time, frequency to user setting in user collection in firestore. 
    ```dart
        class User {
            final bool isVerified;
            final UserSetting userSetting;
            final Role role;
            final String documentId;
            final Set<String> fcmTokens;
            final MillisecondsSinceEpoch? lastReceived;
        }
        ```

# Project structure
- Code flow: ```flutter widget -> providers -> services -> repositories```
- All frontend/UI code stays in ```features``` folder.
- Each feature in features folder contains ```providers, screeens, widgets``` folders.
- ```screens``` only contains flutter widget and some insignicant or removable logic.
- ```widgets``` contains small widgets.
- ```providers``` contains the state logic of designated screen and all significant logic. It also interacts with ```services``` which calls ```repositories``` to make query calls.

- Example:
```dart
class PropertyListScreenNotifier
    extends StateNotifier<PropertyListScreenState> {
  final PropertyService propertyService;
  final SubscriptionService subscriptionService;
  final CacheSubscriptionService cacheSubscriptionService;
  PropertyListScreenNotifier({
    required this.propertyService,
    required this.subscriptionService,
    required this.cacheSubscriptionService,
  }) : super(PropertyListScreenState());

  Future<void> fetchProperties() async {
    state = state.copyWith(
      state:
          state.page > 0
              ? PropertyListScreenConcreteState.fetchingMore
              : PropertyListScreenConcreteState.loading,
    );

    try {
      List<Property> result = await propertyService.getProperties(
        skip: state.page * PRODUCTS_PER_PAGE,
      );
      state = state.copyWith(
        state: PropertyListScreenConcreteState.fetchedAllProperties,
        propertyList: result,
        message: 'Fetching successfully',
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        state: PropertyListScreenConcreteState.error,
        message: 'Error message: ${e.toString()}',
      );
    }
  }
  ...
  ..
}
```