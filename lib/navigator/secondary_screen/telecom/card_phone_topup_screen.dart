import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:intl/intl.dart';

class CardTopupScreen extends StatefulWidget {
  final int walletBalance;
  const CardTopupScreen({super.key, required this.walletBalance});

  @override
  State<CardTopupScreen> createState() => _CardTopupScreenState();
}

class _CardTopupScreenState extends State<CardTopupScreen> {
  String? _selectedProvider;
  int? _selectedAmount;
  final List<int> amounts = [10000, 20000, 50000, 100000, 200000, 500000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mua mã thẻ cào"), backgroundColor: Colors.purple, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chọn nhà mạng", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: ["Viettel", "MobiFone", "VinaPhone"].map((p) {
                      final isSelected = _selectedProvider == p;
                      return ChoiceChip(
                        label: Text(p),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedProvider = p),
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text("Chọn mệnh giá", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: amounts.length,
                    itemBuilder: (context, index) {
                      final amt = amounts[index];
                      final isSelected = _selectedAmount == amt;
                      return InkWell(
                        onTap: () => setState(() => _selectedAmount = amt),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? Colors.purple : Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: Text("${amt ~/ 1000}K", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.purple : Colors.black)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: (_selectedProvider != null && _selectedAmount != null && _selectedAmount! <= widget.walletBalance)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferMoneyFormScreen(
                            account2: BankAccount2(
                              serviceName: "Mua mã thẻ",
                              provider: _selectedProvider!,
                              detail: "Mệnh giá: ${NumberFormat.decimalPattern().format(_selectedAmount)}đ",
                              accountNumber: "CARD/${_selectedProvider}",
                            ),
                            presetAmount: _selectedAmount,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: const Size(double.infinity, 50)),
              child: const Text("MUA NGAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
