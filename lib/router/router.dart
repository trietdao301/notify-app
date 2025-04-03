import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notifyapp/features/auth/screens/login_screen.dart';
import 'package:notifyapp/features/notification_list/screens/notification_list.dart';
import 'package:notifyapp/features/property_list/screens/property_detail_screen.dart';
import 'package:notifyapp/features/property_list/screens/property_list_screen.dart';
import 'package:notifyapp/features/user_setting/screens/user_setting_screen.dart';
import 'package:notifyapp/models/user_setting.dart';
import 'package:notifyapp/router/mobile_screen_wrapper.dart';
import 'package:notifyapp/router/web_screen_wrapper.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/property_list',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return !kIsWeb
            ? MobileScreenWrapper(child: child)
            : WebScreenWrapper(child: child);
      },
      routes: [
        GoRoute(
          path: '/property_list',
          builder: (context, state) => const PropertyListScreen(),
        ),
        GoRoute(
          path: '/property_details/:propertyId',
          builder: (context, state) {
            final propertyId = state.pathParameters['propertyId'];
            if (propertyId == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid Property ID')),
              );
            }
            return PropertyDetailScreen(propertyId: propertyId);
          },
        ),
        GoRoute(
          path: '/notification_list',
          builder: (context, state) => NotificationListScreen(),
        ),
        GoRoute(
          path: '/user_setting',
          builder: (context, state) => UserSettingScreen(),
        ),
      ],
    ),
    // Optional: Add login route if needed
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
  ],
  redirect: (context, state) async {
    return null;
  },
  errorBuilder:
      (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
);
