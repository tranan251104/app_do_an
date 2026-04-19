import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ElectricBillScreen extends StatelessWidget {
  const ElectricBillScreen({super.key});

  final List<Map<String, dynamic>> electricPartners = const [
    {
      "name": "EVN",
      "slogan": "Tập đoàn Điện lực Việt Nam",
      "services": [
        {
          "type": "Thanh toán tiền điện",
          "url": "https://cskh.npc.com.vn/DichVuTTCSKH/",
          "promo": "Giảm 10% khi thanh toán online"
        },
        {
          "type": "Tra cứu hóa đơn",
          "url": "https://cskh.npc.com.vn/DichVuTTCSKH/",
          "promo": "Miễn phí tra cứu"
        },
      ]
    },
    {
      "name": "Điện lực Miền Bắc",
      "slogan": "EVN NPC - Northern Power",
      "services": [
        {
          "type": "Thanh toán tiền điện",
          "url": "https://cskh.npc.com.vn/",
          "promo": "Hỗ trợ thanh toán 24/7"
        },
      ]
    },
    {
      "name": "Điện lực Miền Nam",
      "slogan": "EVN SPC - Southern Power",
      "services": [
        {
          "type": "Thanh toán tiền điện",
          "url": "https://cskh.evnspc.vn/",
          "promo": "Không tính phí giao dịch"
        },
      ]
    },
  ];

  Future<void> _openWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Không mở được $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán tiền điện"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: electricPartners.length,
        itemBuilder: (context, index) {
          final partner = electricPartners[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ExpansionTile(
              title: Text(partner["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(partner["slogan"]),
              children: (partner["services"] as List).map((service) {
                return ListTile(
                  title: Text(service["type"]),
                  subtitle: Text("🔥 ${service["promo"]}"),
                  trailing: ElevatedButton(
                    onPressed: () => _openWebsite(service["url"]),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Text("Xem chi tiết"),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
