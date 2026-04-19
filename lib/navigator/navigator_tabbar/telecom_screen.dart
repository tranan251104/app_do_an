import 'package:app_do_an/navigator/secondary_screen/telecom/card_phone_topup_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/internet_tv_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/phone_topup_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/data_3G_4G_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/music_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/roadming_screen.dart';

class TelecomScreen extends StatelessWidget {
  final int walletBalance; //  nhận từ HomeTabbar
  const TelecomScreen({
    super.key,
    required this.walletBalance,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> telecomServices = [
      {
        "icon": Icons.phone_android,
        "label": "Nạp điện thoại",
        "screen": PhoneTopupScreen(walletBalance: walletBalance),
      },
      {
        "icon": Icons.credit_card, 
        "label": "Mua thẻ cào",
        "screen": CardTopupScreen(walletBalance: walletBalance)
      },
      {
        "icon": Icons.network_wifi, 
        "label": "Đăng ký 3G/4G",
        "screen": Register4GScreen(walletBalance: walletBalance)
        },
      {
        "icon": Icons.tv, 
        "label": "Internet/Truyền hình",
        "screen": InternetTVScreen(walletBalance: walletBalance)
      },
      {
        "icon": Icons.receipt_long, 
        "label": "Chuyển vùng quốc tế",
        "screen": RoamingScreen(walletBalance: walletBalance)
      },
      {
        "icon": Icons.music_note, 
        "label": "Đăng kí nhạc chờ",
        "screen": RbtScreen(walletBalance: walletBalance,)
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dịch vụ Viễn thông"),
        backgroundColor: Colors.purple,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: telecomServices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final item = telecomServices[index];
          return GestureDetector(
            onTap: () {
              if (item["screen"] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item["screen"]),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("🚧 ${item["label"]} đang phát triển")),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["icon"], color: Colors.purple, size: 40),
                  const SizedBox(height: 10),
                  Text(item["label"], textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

