import 'package:app_do_an/navigator/secondary_screen/bill/eletric_bill_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/home_bill_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/learning_bill_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/water_bill_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/internet_bill_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/tv_bill_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/phone_bill_screen.dart';

class BillScreen extends StatelessWidget {
  const BillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bills = [
      {"icon": Icons.lightbulb, "label": "Điện", "screen": const ElectricBillScreen()},
      {"icon": Icons.water_drop, "label": "Nước", "screen": const WaterBillScreen()},
      {"icon": Icons.wifi, "label": "Internet", "screen": const InternetBillScreen()},
      {"icon": Icons.tv, "label": "Truyền hình", "screen": const TVBillScreen()},
      {"icon": Icons.school, "label": "Học phí", "screen": const LearningBillScreen()},
      {"icon": Icons.phone, "label": "Điện thoại cố định", "screen": const PhoneBillScreen()},
      {"icon": Icons.home, "label": "Chung cư / Nhà ở", "screen": const HomeBillScreen()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán hóa đơn"),
        backgroundColor: Colors.purple,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final bill = bills[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => bill["screen"]),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(bill['icon'], size: 50, color: Colors.purple),
                  const SizedBox(height: 12),
                  Text(
                    bill['label'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
