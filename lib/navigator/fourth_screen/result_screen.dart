import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionResultScreen extends StatelessWidget {
  final String bankName;
  final String accountName;
  final int amount;
  final String time;
  final bool isServiceTransaction; // 🔹 true = dịch vụ, false = chuyển tiền

  const TransactionResultScreen({
    super.key,
    required this.bankName,
    required this.accountName,
    required this.amount,
    required this.time,
    this.isServiceTransaction = false, // mặc định là chuyển tiền
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Card thông tin giao dịch
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 80),
                    const SizedBox(height: 12),
                    const Text(
                      "Giao dịch thành công",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$amount VND",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoRow("Thời gian giao dịch", time),

                    // 🔹 Nếu là dịch vụ thì chỉ hiện dịch vụ
                    if (isServiceTransaction)
                      _infoRow("Dịch vụ", accountName)
                    else ...[
                      _infoRow("Ngân hàng liên kết", bankName),
                      _infoRow("Tên tài khoản nhận", accountName),
                    ],

                    _infoRow("Số tiền", "$amount VND"),
                    _infoRow("Phí giao dịch", "Miễn phí"),
                  ],
                ),
              ),
            ),

            // 🔹 2 nút hành động
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        context.go('/tabbar');
                      },
                      child: const Text("Trang chủ"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.go('/transfer');
                      },
                      child: const Text("Tiếp tục chuyển tiền"),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}



