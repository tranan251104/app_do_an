import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class LotteryScreen extends StatefulWidget {
  final int walletBalance;

  const LotteryScreen({super.key, required this.walletBalance});

  @override
  State<LotteryScreen> createState() => _LotteryScreenState();
}

class _LotteryScreenState extends State<LotteryScreen> {
  final int ticketPrice = 10000;
  String lotteryType = "Xổ số truyền thống";
  int ticketCount = 1; // số lượng vé mặc định = 1

  /// Danh sách controllers cho mỗi vé
  late List<List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers =
        List.generate(ticketCount, (_) => List.generate(6, (_) => TextEditingController()));
  }

  /// Random số cho tất cả vé
  void _randomNumbers() {
    final random = Random();
    for (var ticket in _controllers) {
      for (int i = 0; i < 6; i++) {
        ticket[i].text = random.nextInt(10).toString();
      }
    }
    setState(() {});
  }

  /// Xử lý mua vé
  void _buyTicket() {
    final totalPrice = ticketPrice * ticketCount;

    if (totalPrice > widget.walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Số dư ví không đủ (${totalPrice}đ cần thiết)")),
      );
      return;
    }

    // Kiểm tra từng vé đủ 6 số chưa
    for (int t = 0; t < ticketCount; t++) {
      final numbers = _controllers[t].map((c) => c.text).toList();
      if (numbers.any((n) => n.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Vé ${t + 1} chưa nhập đủ 6 số")),
        );
        return;
      }
    }

    // Gom toàn bộ vé thành 1 string
    final ticketDetails = _controllers.map((ticket) {
      return ticket.map((c) => c.text).join();
    }).join(" | ");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(
          account: PaymentAccount.fromService(
            serviceName: "Mua vé số",
            provider: lotteryType,
            detail: "Các vé: $ticketDetails",
            accountNumber: "LOTTO/$lotteryType/$ticketDetails",
          ),
          presetAmount: totalPrice,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var ticket in _controllers) {
      for (var c in ticket) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = ticketPrice * ticketCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mua vé số"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chọn loại vé số:", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: lotteryType,
              items: const [
                DropdownMenuItem(
                  value: "Xổ số truyền thống",
                  child: Text("Xổ số truyền thống"),
                ),
                DropdownMenuItem(
                  value: "Vietlott 6/55",
                  child: Text("Vietlott 6/55"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  lotteryType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("Chọn số lượng vé:", style: TextStyle(fontSize: 16)),
            DropdownButton<int>(
              value: ticketCount,
              items: List.generate(5, (i) {
                final count = i + 1;
                return DropdownMenuItem(
                  value: count,
                  child: Text("$count vé"),
                );
              }),
              onChanged: (value) {
                setState(() {
                  ticketCount = value!;
                  _initControllers();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ticketCount,
                itemBuilder: (context, tIndex) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vé ${tIndex + 1}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 40,
                            child: TextField(
                              controller: _controllers[tIndex][i],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: _randomNumbers,
                icon: const Icon(Icons.casino),
                label: const Text("Chọn nhanh"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _buyTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                child: Text("Mua ngay - ${totalPrice}đ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
