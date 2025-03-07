// import 'package:flutter/material.dart';
// import 'package:notifyapp/models/house.dart';

// class HouseDetailScreen extends StatelessWidget {
//   final House house;

//   HouseDetailScreen({required this.house});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(house.description)),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Details', style: Theme.of(context).textTheme.titleLarge),
//             Text('Address: ${house.address}'),
//             Text('Price: \$${house.listing.price.amount.toStringAsFixed(0)}'),
//             SizedBox(height: 16),
//             Text('Alerts', style: Theme.of(context).textTheme.titleLarge),
//             // if (house.alerts.isEmpty)
//             //   Text('No active alerts')
//             // else
//             //   ...house.alerts.map((alert) => ListTile(title: Text(alert))),
//             SizedBox(height: 16),
//             Text(
//               'Change History',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             // ...house.majorEvents.map(
//             //   (event) => ListTile(
//             //     title: Text(event.eventName),
//             //     subtitle: Text(
//             //       '${event.eventDescription} - ${event.eventDateTime.toString()}',
//             //     ),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
