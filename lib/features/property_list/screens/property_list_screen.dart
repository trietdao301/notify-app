import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:notifyapp/features/property_list/providers/propert_list_state.dart';
import 'package:notifyapp/features/property_list/providers/property_list_provider.dart';
import 'package:notifyapp/features/property_list/widgets/property_card.dart';

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyListScreenProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              "Properties",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: switch (state.state) {
                (PropertyListScreenConcreteState.fetchedAllProperties ||
                    PropertyListScreenConcreteState.fetchingMore) =>
                  ListView.builder(
                    itemCount: state.propertyList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: PropertyCard(
                          property: state.propertyList[index],
                        ),
                      );
                    },
                  ),
                PropertyListScreenConcreteState.error => Text(
                  'Error: ${state.message}',
                ),
                PropertyListScreenConcreteState.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                PropertyListScreenConcreteState.initial => Text(
                  'Initial state',
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
