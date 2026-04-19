import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class CardTopupScreen extends StatefulWidget {
  final int walletBalance;

  const CardTopupScreen({
    super.key,
    required this.walletBalance,
  });

  @override
  State<CardTopupScreen> createState() => _CardTopupScreenState();
}

class _CardTopupScreenState extends State<CardTopupScreen> {
  String? _selectedProvider;
  int? _selectedAmount;

  final List<String> providers = ["Viettel", "Mobifone", "Vinaphone"];
  final List<int> amounts = [
    10000,
    20000,
    50000,
    100000,
    200000,
    300000,
    500000
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mua thẻ cào"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Chọn nhà mạng
            const Text("Nhà mạng",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: providers.map((p) {
                final isSelected = _selectedProvider == p;
                return ChoiceChip(
                  label: Text(p),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedProvider = p);
                  },
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 🔹 Chọn mệnh giá
            const Text("Mệnh giá",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text("${amount ~/ 1000}K"),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedAmount = amount);
                  },
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            // 🔹 Nút mua thẻ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedProvider != null && _selectedAmount != null)
                    ? () {
                        final amount = _selectedAmount!;
                        if (amount > widget.walletBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("❌ Số dư ví không đủ")),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferMoneyFormScreen(
                              account2: BankAccount2(
                                serviceName: "Mua thẻ cào",
                                provider: _selectedProvider!,
                                detail: "${amount ~/ 1000}K",
                                accountNumber:
                                    "CARD/${_selectedProvider!}/$amount",
                              ),
                              presetAmount: amount,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    const Text("Mua ngay", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

