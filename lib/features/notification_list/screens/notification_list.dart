import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/notification_list/providers/notification_list_provider.dart';
import 'package:notifyapp/features/notification_list/providers/notification_list_state.dart';
import 'package:notifyapp/features/notification_list/widgets/notification_card.dart';
import 'package:notifyapp/shared/providers/notification_stream_provider.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key}); // Added super.key for consistency

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListState();
}

class _NotificationListState extends ConsumerState<NotificationListScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListNotifierProvider);

    return Material(
      color:
          Theme.of(
            context,
          ).scaffoldBackgroundColor, // Match WebScreenWrapper’s Scaffold
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Notification",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Expanded(
                child: switch (state.state) {
                  (NotificationListScreenConcreteState
                          .fetchedAllNotifications ||
                      NotificationListScreenConcreteState.fetchingMore) =>
                    ListView.separated(
                      itemCount: state.notificationList.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        return NotificationCard(
                          title:
                              "Property ${state.notificationList[index].propertyId} Changed",
                          createAt:
                              "${state.notificationList[index].dateTime.toString()} UTC",
                          description:
                              state.notificationList[index].changesToString(),
                          onReadPressed:
                              () => _onReadButton(
                                notificationId:
                                    state.notificationList[index].id,
                              ),
                        );
                      },
                    ),
                  NotificationListScreenConcreteState.error => Center(
                    child: Text('Error: ${state.message}'),
                  ),
                  NotificationListScreenConcreteState.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  NotificationListScreenConcreteState.initial => Center(
                    child: Text('Initial state'),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReadButton({required String notificationId}) {
    ref
        .read(notificationListNotifierProvider.notifier)
        .markAsRead(notificationId);
  }
}
