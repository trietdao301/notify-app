import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:notifyapp/models/property.dart';

class PropertyDetailScreen extends ConsumerWidget {
  String propertyId;

  PropertyDetailScreen({required this.propertyId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text("property detail");
  }
}
