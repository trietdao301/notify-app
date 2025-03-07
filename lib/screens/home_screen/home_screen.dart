import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/providers/property_provider.dart';
import 'property_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseList = ref.watch(propertyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            // onPressed: () => Navigator.pushNamed(context, '/preferences'),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.help),
            // onPressed: () => Navigator.pushNamed(context, '/help'),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              child: switch (houseList) {
                AsyncData(:final value) => ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PropertyCard(property: value[index]),
                    );
                  },
                ),
                AsyncError(:final error) => Text('Error: $error'),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Admin Dashboard'),
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          ],
        ),
      ),
    );
  }
}
