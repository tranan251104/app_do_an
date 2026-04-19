import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class DataPackage {
  final String name;
  final String data;
  final String price;
  final String validity;

  DataPackage({
    required this.name,
    required this.data,
    required this.price,
    required this.validity,
  });
}

class Register4GScreen extends StatefulWidget {
  final int walletBalance; // ✅ truyền vào từ TelecomScreen

  const Register4GScreen({super.key, required this.walletBalance});

  @override
  State<Register4GScreen> createState() => _Register4GScreenState();
}

class _Register4GScreenState extends State<Register4GScreen> {
  final Map<String, List<DataPackage>> telcoPackages = {
    "Viettel": [
      DataPackage(name: "ST15K", data: "3GB", price: "15,000đ", validity: "3 ngày"),
      DataPackage(name: "ST30K", data: "7GB", price: "30,000đ", validity: "7 ngày"),
      DataPackage(name: "ST70K", data: "15GB", price: "70,000đ", validity: "30 ngày"),
      DataPackage(name: "ST90", data: "20GB", price: "90,000đ", validity: "30 ngày"),
      DataPackage(name: "ST120K", data: "60GB", price: "120,000đ", validity: "30 ngày"),
      DataPackage(name: "ST150", data: "90GB", price: "150,000đ", validity: "30 ngày"),
      DataPackage(name: "ST200K", data: "120GB", price: "200,000đ", validity: "30 ngày"),
      DataPackage(name: "ST250", data: "150GB", price: "250,000đ", validity: "30 ngày"),
      DataPackage(name: "ST300K", data: "180GB", price: "300,000đ", validity: "30 ngày"),
      DataPackage(name: "ST500", data: "300GB", price: "500,000đ", validity: "30 ngày"),
    ],
    "Vinaphone": [
      DataPackage(name: "VD30", data: "7GB", price: "30,000đ", validity: "7 ngày"),
      DataPackage(name: "VD50", data: "12GB", price: "50,000đ", validity: "30 ngày"),
      DataPackage(name: "VD70", data: "15GB", price: "70,000đ", validity: "30 ngày"),
      DataPackage(name: "VD89", data: "30GB", price: "89,000đ", validity: "30 ngày"),
      DataPackage(name: "VD120", data: "60GB", price: "120,000đ", validity: "30 ngày"),
      DataPackage(name: "VD149", data: "75GB", price: "149,000đ", validity: "30 ngày"),
      DataPackage(name: "VD200", data: "100GB", price: "200,000đ", validity: "30 ngày"),
      DataPackage(name: "VD250", data: "150GB", price: "250,000đ", validity: "30 ngày"),
      DataPackage(name: "VD300", data: "200GB", price: "300,000đ", validity: "30 ngày"),
      DataPackage(name: "VD500", data: "400GB", price: "500,000đ", validity: "30 ngày"),
    ],
    "Mobifone": [
      DataPackage(name: "M10", data: "3GB", price: "10,000đ", validity: "1 ngày"),
      DataPackage(name: "M25", data: "6GB", price: "25,000đ", validity: "7 ngày"),
      DataPackage(name: "M50", data: "12GB", price: "50,000đ", validity: "30 ngày"),
      DataPackage(name: "M70", data: "18GB", price: "70,000đ", validity: "30 ngày"),
      DataPackage(name: "M90", data: "25GB", price: "90,000đ", validity: "30 ngày"),
      DataPackage(name: "MAX100", data: "30GB", price: "100,000đ", validity: "30 ngày"),
      DataPackage(name: "MAX200", data: "70GB", price: "200,000đ", validity: "30 ngày"),
      DataPackage(name: "MAX300", data: "120GB", price: "300,000đ", validity: "30 ngày"),
      DataPackage(name: "MAX400", data: "200GB", price: "400,000đ", validity: "30 ngày"),
      DataPackage(name: "MAX500", data: "300GB", price: "500,000đ", validity: "30 ngày"),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: telcoPackages.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đăng ký 3G/4G"),
          backgroundColor: Colors.purple,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: telcoPackages.keys.map((telco) => Tab(text: telco)).toList(),
          ),
        ),
        body: TabBarView(
          children: telcoPackages.entries.map((entry) {
            final telco = entry.key;
            final packages = entry.value;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final pkg = packages[index];
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
                    title: Text("$telco - ${pkg.name}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Dung lượng: ${pkg.data}\nGiá: ${pkg.price}\nThời hạn: ${pkg.validity}"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (amount > widget.walletBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Số dư ví không đủ để đăng ký gói này"),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferMoneyFormScreen(
                              account2: BankAccount2(   // ✅ dùng BankAccount2 thay vì BankAccount1
                                serviceName: "Đăng ký gói $telco",
                                provider: telco,
                                detail: pkg.name,
                                accountNumber: "DATA/$telco/${pkg.name}",
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

