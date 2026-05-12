import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:go_router/go_router.dart';

class TransactionResultScreen extends StatelessWidget {
  final String bankName;
  final String accountName;
  final int amount;
  final String time;
  final bool isServiceTransaction; 

  const TransactionResultScreen({
    super.key,
    required this.bankName,
    required this.accountName,
    required this.amount,
    required this.time,
    this.isServiceTransaction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        bottom: false, // Để màu nền tràn xuống dưới
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
                    const SizedBox(height: 20),
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
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
                    const SizedBox(height: 30),
                    _infoRow("Thời gian giao dịch", time),

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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), // Tăng padding dưới để tránh bị đè
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        // 🔹 Sử dụng Navigator để đẩy về root Tabbar một cách an toàn
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const TabbarScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text("Trang chủ", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        // Nếu trang chủ dùng Navigator thì Tiếp tục chuyển tiền cũng nên dùng để đồng bộ
                        context.go('/transfer');
                      },
                      child: const Text("Tiếp tục chuyển tiền", style: TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
