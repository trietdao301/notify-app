import 'dart:js_interop'; // Replace dart:js with this
import 'dart:js_interop_unsafe'; // Needed for calling the function

// Call javascript script to show notification
@JS('showWebNotification')
external void showWebNotification(String title, String body);
