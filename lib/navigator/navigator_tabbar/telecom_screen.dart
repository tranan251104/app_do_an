import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/phone_topup_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/card_phone_topup_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/generic_package_screen.dart';
import 'package:app_do_an/navigator/service/app_data.dart';

class TelecomScreen extends StatelessWidget {
  final int walletBalance;
  const TelecomScreen({super.key, required this.walletBalance});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        "icon": Icons.phone_android,
        "label": "Nạp điện thoại",
        "screen": PhoneTopupScreen(walletBalance: walletBalance),
      },
      {
        "icon": Icons.credit_card,
        "label": "Mua thẻ cào",
        "screen": CardTopupScreen(walletBalance: walletBalance),
      },
      {
        "icon": Icons.network_wifi,
        "label": "Đăng ký 3G/4G",
        "screen": GenericPackageScreen(
          title: "Đăng ký 3G/4G",
          providers: ["Viettel", "MobiFone", "VinaPhone"],
          packages: AppData.dataPackages,
        ),
      },
      {
        "icon": Icons.music_note,
        "label": "Nhạc chờ",
        "screen": GenericPackageScreen(
          title: "Đăng ký Nhạc chờ",
          providers: ["Viettel iMuzik", "MobiFone FunRing"],
          packages: AppData.musicPackages,
        ),
      },
      {
        "icon": Icons.tv,
        "label": "Internet/TV",
        "screen": GenericPackageScreen(
          title: "Internet/Truyền hình",
          providers: ["FPT Play", "K+", "VieON"],
          packages: AppData.tvPackages,
        ),
      },
      {
        "icon": Icons.receipt_long,
        "label": "Chuyển vùng",
        "screen": GenericPackageScreen(
          title: "Chuyển vùng quốc tế",
          providers: ["Viettel", "VinaPhone"],
          packages: [
            PackageModel(name: "IR_DAILY", price: 50000, description: "Data roaming 1 ngày"),
          ],
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dịch vụ Viễn thông"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final item = services[index];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item["screen"])),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["icon"], color: Colors.purple, size: 40),
                  const SizedBox(height: 12),
                  Text(item["label"], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
