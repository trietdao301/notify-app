import 'package:flutter/material.dart';
import 'package:notifyapp/screens/home_screen/property_card.dart';

class PropertyInfo extends StatelessWidget {
  const PropertyInfo({super.key, required this.widget});

  final PropertyCard widget;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.property.instrumentTypeName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Parcel ID: ${widget.property.parcelId}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Owner: ${widget.property.lastNameOrCorpName}${widget.property.firstName != null ? ", ${widget.property.firstName}" : ""}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${widget.property.recordingDate ?? "N/A"}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
