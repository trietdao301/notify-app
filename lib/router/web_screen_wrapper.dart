import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/notification_list/screens/notification_list.dart';
import 'package:notifyapp/features/property_list/screens/property_list_screen.dart';
import 'package:notifyapp/shared/providers/notification_stream_provider.dart';

class WebScreenWrapper extends ConsumerStatefulWidget {
  final Widget child;
  WebScreenWrapper({required this.child});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _WebNavigationBarState();
  }
}

class _WebNavigationBarState extends ConsumerState<WebScreenWrapper> {
  int currentIndex = 0;
  // Map navigation bar indices to GoRouter paths
  static const List<String> _routes = [
    '/property_list',
    '/notification_list',
    '/property_list',
  ];
  @override
  Widget build(BuildContext context) {
    // Get the current notification count from the provider
    final notificationCount = ref.watch(unreadNotificationCountProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,

        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),

          child: Row(
            children: [
              // Logo and app name
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.phone_android, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'App',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              // Spacer
              const SizedBox(width: 48),

              // Navigation links
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavItem(
                      title: 'Properties',
                      isSelected: currentIndex == 0,
                      onTap: () {
                        setState(() {
                          currentIndex = 0;
                        });
                        context.go(_routes[0]);
                      },
                    ),
                    _NavItem(
                      title: 'Notifications',
                      isSelected: currentIndex == 1,
                      onTap: () {
                        setState(() {
                          currentIndex = 1;
                        });
                        context.go(_routes[1]);
                      },
                    ),
                    _NavItem(
                      title: 'Account',
                      isSelected: currentIndex == 2,
                      onTap: () {
                        setState(() {
                          currentIndex = 2;
                        });
                        context.go(_routes[2]);
                      },
                    ),
                  ],
                ),
              ),

              // Right side icons
              Row(
                children: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 300,
                      ), // Animation speed
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return ScaleTransition(
                          scale: animation, // Scales the icon in/out
                          child: child,
                        );
                      },
                      child:
                          notificationCount == 0
                              ? const Icon(Icons.notifications_none_outlined)
                              : Badge.count(
                                key: ValueKey(
                                  notificationCount,
                                ), // Trigger animation on count change
                                count: notificationCount,
                                child:
                                    notificationCount <= 0
                                        ? const Icon(
                                          Icons.notifications_none_outlined,
                                        )
                                        : const Icon(Icons.notifications),
                              ),
                    ),
                    onPressed: () {
                      setState(() {
                        currentIndex = 1;
                      });
                      context.go(_routes[1]);
                    },
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/200/300?grayscale',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Theme toggle icon
                  IconButton(
                    icon: Icon(
                      isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Toggle theme logic here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
    );
  }
}

// Updated _NavItem to include onTap callback
class _NavItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({required this.title, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: TextButton(
        onPressed: onTap, // Use the provided onTap callback
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
