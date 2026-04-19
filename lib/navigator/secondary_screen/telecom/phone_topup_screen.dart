import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:intl/intl.dart';

class PhoneTopupScreen extends StatefulWidget {
  final int walletBalance;

  const PhoneTopupScreen({
    super.key,
    required this.walletBalance,
  });

  @override
  State<PhoneTopupScreen> createState() => _PhoneTopupScreenState();
}

class _PhoneTopupScreenState extends State<PhoneTopupScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  int? _selectedAmount;

  final List<int> amounts = [10000, 20000, 50000, 100000, 200000];

  bool get isFormValid {
    final cleanVal = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final entered = int.tryParse(cleanVal) ?? 0;
    if (entered > widget.walletBalance) return false;
    return _phoneController.text.isNotEmpty && entered > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nạp tiền điện thoại"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Nhập số điện thoại
            const Text("Số điện thoại",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "Nhập số điện thoại",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            /// 🔹 Chọn mệnh giá
            const Text("Chọn mệnh giá",
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
                    setState(() {
                      _selectedAmount = amount;
                      _amountController.text = amount.toString();
                    });
                  },
                  selectedColor: Colors.purple,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            /// 🔹 Nhập số tiền khác
            const Text("Hoặc nhập số tiền khác",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập số tiền (VNĐ)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: (_amountController.text.isNotEmpty &&
                        int.tryParse(_amountController.text) != null &&
                        int.parse(_amountController.text) >
                            widget.walletBalance)
                    ? "❌ Số dư ví không đủ"
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _selectedAmount = null;
                });
              },
            ),

            const SizedBox(height: 12),
            Text(
              "Số dư ví hiện tại: ₫${NumberFormat.decimalPattern().format(widget.walletBalance)}",
              style: const TextStyle(color: Colors.grey),
            ),

            const Spacer(),

            // 🔹 Nút tiếp tục
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid
                    ? () {
                        final cleanVal = _amountController.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        final amount = int.parse(cleanVal);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferMoneyFormScreen(
                              account2: BankAccount2(
                                serviceName: "Nạp tiền điện thoại",
                                provider: "Điện thoại",
                                detail: _phoneController.text,
                                accountNumber: "TOPUP/${_phoneController.text}",
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
                child: const Text("Tiếp tục", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}



