import 'package:app_do_an/navigator/secondary_screen/transtation/bus_route_list_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transtation/car_rental_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transtation/plant_route_list_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transtation/train_travel.dart';
import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/transtation/taxi_travel.dart';

class TravelScreen extends StatelessWidget {
  final int walletBalance;

  const TravelScreen({super.key, required this.walletBalance});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> travelServices = [
      {"icon": Icons.local_taxi, "label": "Đặt taxi/xe công nghệ"},
      {"icon": Icons.flight, "label": "Vé máy bay"},
      {"icon": Icons.train, "label": "Vé tàu hỏa"},
      {"icon": Icons.directions_bus, "label": "Vé xe khách"},
      {"icon": Icons.directions_car, "label": "Thuê xe tự lái"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đi lại"),
        backgroundColor: Colors.purple,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: travelServices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final service = travelServices[index];
          return InkWell(
           onTap: () {
            switch (service['label']) {
              case "Đặt taxi/xe công nghệ":
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TravelTaxiScreen(),
                  ),
                );
              case "Vé tàu hỏa":
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => TrainRouteListScreen(walletBalance: walletBalance)
                  )
                );
              case "Vé máy bay":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaneRouteListScreen(walletBalance: walletBalance)
                  )
                );
              case "Vé xe khách":
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => BusTicketFilterScreen(walletBalance: walletBalance)
                  )
                );
              case "Thuê xe tự lái":
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => CarRentalScreen(walletBalance: walletBalance))
                );

              break;
      default:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚧 ${service['label']} đang phát triển")),
      );
      break;
  }
},

            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(service["icon"], size: 48, color: Colors.purple),
                  const SizedBox(height: 8),
                  Text(
                    service["label"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
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
