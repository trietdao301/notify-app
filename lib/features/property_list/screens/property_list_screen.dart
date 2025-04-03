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
                "Properties",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Expanded(
                child: switch (state.state) {
                  (PropertyListScreenConcreteState.fetchedAllProperties ||
                      PropertyListScreenConcreteState.fetchingMore) =>
                    ListView.separated(
                      itemCount: state.propertyList.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        return PropertyCard(
                          property: state.propertyList[index],
                        );
                      },
                    ),
                  PropertyListScreenConcreteState.error => Center(
                    child: Text('Error: ${state.message}'),
                  ),
                  PropertyListScreenConcreteState.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  PropertyListScreenConcreteState.initial => Center(
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
}
