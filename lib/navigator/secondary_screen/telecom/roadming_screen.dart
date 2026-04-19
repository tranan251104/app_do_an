import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class ServicePackage {
  final String name;
  final String country;
  final String data;
  final String price;
  final String validity;

  ServicePackage({
    required this.name,
    required this.country,
    required this.data,
    required this.price,
    required this.validity,
  });
}

class RoamingScreen extends StatefulWidget {
  final int walletBalance;

  const RoamingScreen({super.key, required this.walletBalance});

  @override
  State<RoamingScreen> createState() => _RoamingScreenState();
}

class _RoamingScreenState extends State<RoamingScreen> {
  final Map<String, List<ServicePackage>> roamingPackages = {
    "Viettel": [
      ServicePackage(
          name: "Data 7 ngày",
          country: "Nhật Bản",
          data: "3GB",
          price: "350,000đ",
          validity: "7 ngày"),
      ServicePackage(
          name: "Data 5 ngày",
          country: "Hàn Quốc",
          data: "2GB",
          price: "250,000đ",
          validity: "5 ngày"),
    ],
    "Vinaphone": [
      ServicePackage(
          name: "Data 5 ngày",
          country: "Singapore",
          data: "2GB",
          price: "220,000đ",
          validity: "5 ngày"),
      ServicePackage(
          name: "Data 7 ngày",
          country: "Úc",
          data: "3GB",
          price: "400,000đ",
          validity: "7 ngày"),
    ],
    "Mobifone": [
      ServicePackage(
          name: "Data 3 ngày",
          country: "Malaysia",
          data: "1GB",
          price: "150,000đ",
          validity: "3 ngày"),
      ServicePackage(
          name: "Data 7 ngày",
          country: "Pháp",
          data: "4GB",
          price: "600,000đ",
          validity: "7 ngày"),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: roamingPackages.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Roaming Quốc tế"),
          backgroundColor: Colors.purple,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: roamingPackages.keys.map((p) => Tab(text: p)).toList(),
          ),
        ),
        body: TabBarView(
          children: roamingPackages.entries.map((entry) {
            final provider = entry.key;
            final pkgs = entry.value;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pkgs.length,
              itemBuilder: (context, index) {
                final pkg = pkgs[index];
                final cleanPrice = pkg.price.replaceAll(RegExp(r'[^0-9]'), '');
                final amount = int.tryParse(cleanPrice) ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text("${pkg.country} - ${pkg.name} ($provider)",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Dung lượng: ${pkg.data}\nGiá: ${pkg.price}\nThời hạn: ${pkg.validity}"),
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
                                serviceName: "Roaming Quốc tế",
                                provider: provider,
                                detail: "${pkg.country} - ${pkg.name}",
                                accountNumber: "ROAM/$provider/${pkg.country}",
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
