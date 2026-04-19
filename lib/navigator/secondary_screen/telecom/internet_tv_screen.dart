import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class ServicePackage {
  final String name;
  final String detail;
  final String price;
  final String validity;

  ServicePackage({
    required this.name,
    required this.detail,
    required this.price,
    required this.validity,
  });
}

class InternetTVScreen extends StatefulWidget {
  final int walletBalance; // ✅ nhận từ ngoài

  const InternetTVScreen({super.key, required this.walletBalance});

  @override
  State<InternetTVScreen> createState() => _InternetTVScreenState();
}

class _InternetTVScreenState extends State<InternetTVScreen> {
  final Map<String, List<ServicePackage>> providers = {
    "VNPT": [
      ServicePackage(
          name: "Fiber 50Mbps",
          detail: "Tốc độ 50Mbps",
          price: "165,000đ",
          validity: "1 tháng"),
      ServicePackage(
          name: "Fiber 100Mbps",
          detail: "Tốc độ 100Mbps",
          price: "220,000đ",
          validity: "1 tháng"),
    ],
    "FPT": [
      ServicePackage(
          name: "FPT Super 80",
          detail: "Tốc độ 80Mbps",
          price: "190,000đ",
          validity: "1 tháng"),
      ServicePackage(
          name: "FPT Super 150",
          detail: "Tốc độ 150Mbps",
          price: "250,000đ",
          validity: "1 tháng"),
    ],
    "Viettel": [
      ServicePackage(
          name: "Home Net 1",
          detail: "Tốc độ 100Mbps",
          price: "200,000đ",
          validity: "1 tháng"),
      ServicePackage(
          name: "Home Net 2",
          detail: "Tốc độ 150Mbps",
          price: "260,000đ",
          validity: "1 tháng"),
    ],
    "K+": [
      ServicePackage(
          name: "K+ Premium",
          detail: "200 kênh truyền hình",
          price: "125,000đ",
          validity: "1 tháng"),
      ServicePackage(
          name: "K+ Sport",
          detail: "Trọn gói bóng đá + 150 kênh",
          price: "150,000đ",
          validity: "1 tháng"),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: providers.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Internet/Truyền hình"),
          backgroundColor: Colors.purple,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: providers.keys.map((p) => Tab(text: p)).toList(),
          ),
        ),
        body: TabBarView(
          children: providers.entries.map((entry) {
            final provider = entry.key;
            final pkgs = entry.value;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pkgs.length,
              itemBuilder: (context, index) {
                final pkg = pkgs[index];
                final cleanPrice =
                    pkg.price.replaceAll(RegExp(r'[^0-9]'), '');
                final amount = int.tryParse(cleanPrice) ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text("${pkg.name} - $provider",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${pkg.detail}\nGiá: ${pkg.price}\nThời hạn: ${pkg.validity}"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (amount > widget.walletBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "❌ Số dư ví không đủ để đăng ký gói này"),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferMoneyFormScreen(
                              account2: BankAccount2(
                                serviceName: "Internet/Truyền hình",
                                provider: provider,
                                detail: pkg.name,
                                accountNumber: "INETTV/$provider/${pkg.name}",
                              ),
                              presetAmount: amount,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                      child: const Text("Đăng ký"),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}


