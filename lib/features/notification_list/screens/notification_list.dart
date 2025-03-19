import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/features/notification_list/providers/notification_list_provider.dart';
import 'package:notifyapp/features/notification_list/providers/notification_list_state.dart';
import 'package:notifyapp/features/notification_list/widgets/notification_card.dart';
import 'package:notifyapp/shared/providers/notification_stream_provider.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _NotificationListState();
  }
}

class _NotificationListState extends ConsumerState<NotificationListScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              "Notification",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: switch (state.state) {
                (NotificationListScreenConcreteState.fetchedAllNotifications ||
                    NotificationListScreenConcreteState.fetchingMore) =>
                  ListView.builder(
                    itemCount: state.notificationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: NotificationCard(
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
                        ),
                      );
                    },
                  ),
                NotificationListScreenConcreteState.error => Text(
                  'Error: ${state.message}',
                ),
                NotificationListScreenConcreteState.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                NotificationListScreenConcreteState.initial => Text(
                  'Initial state',
                ),
              },
            ),
          ],
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
