import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class TrainRouteListScreen extends StatelessWidget {
  final int walletBalance;
  TrainRouteListScreen({super.key, required this.walletBalance});

  final formatter = NumberFormat("#,###", "vi_VN");

  // 🔽 Danh sách 30 tuyến tàu phổ biến
  final List<Map<String, dynamic>> routes = const [
    {"train": "SE1", "route": "Hà Nội → Sài Gòn"},
    {"train": "SE2", "route": "Sài Gòn → Hà Nội"},
    {"train": "SE3", "route": "Hà Nội → Sài Gòn"},
    {"train": "SE4", "route": "Sài Gòn → Hà Nội"},
    {"train": "SE5", "route": "Hà Nội → Sài Gòn"},
    {"train": "SE6", "route": "Sài Gòn → Hà Nội"},
    {"train": "SE7", "route": "Hà Nội → Sài Gòn"},
    {"train": "SE8", "route": "Sài Gòn → Hà Nội"},
    {"train": "SE9", "route": "Hà Nội → Đà Nẵng"},
    {"train": "SE10", "route": "Đà Nẵng → Hà Nội"},
    {"train": "SE19", "route": "Hà Nội → Đà Nẵng"},
    {"train": "SE20", "route": "Đà Nẵng → Hà Nội"},
    {"train": "SP1", "route": "Hà Nội → Lào Cai"},
    {"train": "SP2", "route": "Lào Cai → Hà Nội"},
    {"train": "SP3", "route": "Hà Nội → Lào Cai"},
    {"train": "SP4", "route": "Lào Cai → Hà Nội"},
    {"train": "HP1", "route": "Hà Nội → Hải Phòng"},
    {"train": "HP2", "route": "Hải Phòng → Hà Nội"},
    {"train": "HP3", "route": "Hà Nội → Hải Phòng"},
    {"train": "HP4", "route": "Hải Phòng → Hà Nội"},
    {"train": "NA1", "route": "Hà Nội → Vinh"},
    {"train": "NA2", "route": "Vinh → Hà Nội"},
    {"train": "TH1", "route": "Hà Nội → Thanh Hóa"},
    {"train": "TH2", "route": "Thanh Hóa → Hà Nội"},
    {"train": "DN1", "route": "Hà Nội → Đồng Hới"},
    {"train": "DN2", "route": "Đồng Hới → Hà Nội"},
    {"train": "NH1", "route": "Hà Nội → Nha Trang"},
    {"train": "NH2", "route": "Nha Trang → Hà Nội"},
    {"train": "SG1", "route": "Sài Gòn → Nha Trang"},
    {"train": "SG2", "route": "Nha Trang → Sài Gòn"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách chuyến tàu"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];

          // ⚡ Giả lập giá vé: SE (300k), SP (200k), HP (100k), NA/TH/DN/NH/SG (150k)
          int basePrice = 150000;
          if (route["train"].toString().startsWith("SE")) basePrice = 300000;
          if (route["train"].toString().startsWith("SP")) basePrice = 200000;
          if (route["train"].toString().startsWith("HP")) basePrice = 100000;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.train, color: Colors.purple),
              title: Text("${route["train"]} - ${route["route"]}"),
              subtitle: Text("💰 Giá vé: ${formatter.format(basePrice)} VND"),
              trailing: ElevatedButton(
                onPressed: () {
                  if (basePrice > walletBalance) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("⚠️ Số dư ví không đủ!")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferMoneyFormScreen(
                        account2: BankAccount2(
                          serviceName: "Đặt vé tàu hỏa",
                          provider: "Đường sắt Việt Nam", // ✅ fix cứng
                          detail: "${route["train"]} - ${route["route"]}",
                          accountNumber: "TRAIN/${route["train"]}",
                        ),
                        presetAmount: basePrice, // ✅ fix số tiền vé
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Đặt vé"),
              ),
            ),
          );
        },
      ),
    );
  }
}
