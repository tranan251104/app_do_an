import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/transtation/generic_travel_search_screen.dart';

class TravelScreen extends StatelessWidget {
  final int walletBalance;
  const TravelScreen({super.key, required this.walletBalance});

  static const services = <Map<String, dynamic>>[
    {"icon": Icons.flight, "label": "Vé máy bay", "type": "plane"},
    {"icon": Icons.train, "label": "Vé tàu hỏa", "type": "train"},
    {"icon": Icons.directions_bus, "label": "Vé xe khách", "type": "bus"},
    {"icon": Icons.local_taxi, "label": "Đặt taxi", "type": "taxi"},
    {"icon": Icons.directions_car, "label": "Thuê xe tự lái", "type": "car"},
  ];

  static Widget serviceScreen(Map<String, dynamic> service) =>
      GenericTravelSearchScreen(title: service['label'], type: service['type']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đi lại"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return InkWell(
            onTap: () {
              AppLogger.action('TRAVEL service selected', {
                'label': service['label'],
                'type': service['type'],
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => serviceScreen(service)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(service["icon"], size: 48, color: Colors.purple),
                  const SizedBox(height: 12),
                  Text(
                    service["label"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
