import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:notifyapp/features/notification_list/screens/notification_list.dart';
import 'package:notifyapp/features/property_list/screens/property_list_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:notifyapp/models/property_notification.dart';
import 'package:notifyapp/shared/providers/notification_stream_provider.dart';

class MobileScreenWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const MobileScreenWrapper({required this.child, super.key});

  @override
  ConsumerState<MobileScreenWrapper> createState() =>
      MobileNavigationBarState();
}

class MobileNavigationBarState extends ConsumerState<MobileScreenWrapper> {
  int currentPageIndex = 0;
  int notificationCounter = 0;
  // Map navigation bar indices to GoRouter paths
  static const List<String> _routes = [
    '/property_list',
    '/notification_list',
    '/property_list', // Replace with actual route for "Likes"
  ];

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(unreadNotificationCountProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 70, // Increased height to match the image
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, -2), // Shadow above the bar
            ),
          ],
        ),
        child: GNav(
          tabActiveBorder: Border.all(color: Colors.black),
          gap: 10,
          color: Colors.grey[600],
          activeColor: Colors.black,
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          iconSize: 20,
          textStyle: TextStyle(fontSize: 16, color: Colors.black),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14.5),
          duration: Duration(milliseconds: 800),
          tabs: [
            GButton(
              icon: LineIcons.home,
              onPressed: () {
                setState(() {
                  currentPageIndex = 0;
                });
                context.go(_routes[0]);
              },
            ),
            GButton(
              icon:
                  LineIcons
                      .heart, // Main icon (won't be visible if leading is present)
              text: 'Mail',
              leading: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 300,
                ), // Animation duration
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation, // Scale animation
                    child: child,
                  );
                },
                child:
                    counter <= 0
                        ? Icon(
                          LineIcons.envelope,
                          size: 20,
                          color: Colors.black,
                        ) // No badge when counter is 0 or less
                        : Badge(
                          key: ValueKey(
                            counter,
                          ), // Unique key to trigger animation
                          backgroundColor: Colors.red.shade100,
                          textColor: Colors.red.shade900,
                          label: Text(
                            counter.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: const EdgeInsets.all(2),
                          smallSize: 12,
                          alignment: AlignmentDirectional.topEnd,
                          offset: const Offset(5, -7),
                          child: Icon(
                            LineIcons.envelope,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
              ),
              onPressed: () {
                setState(() {
                  currentPageIndex = 1;
                });
                context.go(_routes[1]);
              },
            ),
            GButton(
              icon: LineIcons.search, // Added magnifying glass icon
              onPressed: () {
                setState(() {
                  currentPageIndex = 2;
                });
                context.go(_routes[2]);
              },
            ),
            GButton(
              icon: LineIcons.user,
              text: 'Profile',
              onPressed: () {
                setState(() {
                  currentPageIndex = 1;
                });
                context.go(_routes[1]);
              },
            ),
          ],
        ),
      ),
      body: Center(child: widget.child),
    );
  }
}
