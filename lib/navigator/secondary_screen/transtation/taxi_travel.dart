import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelTaxiScreen extends StatelessWidget {
  const TravelTaxiScreen({super.key});

  final List<Map<String, dynamic>> taxiPartners = const [
    {
      "name": "Grab",
      "slogan": "Đặt xe máy, taxi nhanh chóng",
      "link": "https://www.grab.com/vn/"
    },
    {
      "name": "Be",
      "slogan": "Dịch vụ gọi xe Việt Nam",
      "link": "https://www.be.com.vn/"
    },
    {
      "name": "Gojek",
      "slogan": "Xe ôm, taxi, giao hàng",
      "link": "https://www.gojek.com/vn/"
    },
    {
      "name": "Xanh SM",
      "slogan": "Taxi điện VinFast",
      "link": "https://vinfast.com/vn/vi/xanhsm"
    },
  ];

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Không mở được liên kết: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt Taxi / Xe công nghệ"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: taxiPartners.length,
        itemBuilder: (context, index) {
          final partner = taxiPartners[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                partner["name"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(partner["slogan"]),
              trailing: ElevatedButton(
                onPressed: () => _openLink(partner["link"]),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Tham khảo"),
              ),
            ),
          );
        },
      ),
    );
  }
}
