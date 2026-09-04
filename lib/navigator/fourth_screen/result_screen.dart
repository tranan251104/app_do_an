import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionResultScreen extends StatelessWidget {
  final String bankName;
  final String accountName;
  final int amount;
  final String time;
  final bool isServiceTransaction;
  final bool isSimulation;
  final String? providerReference;

  const TransactionResultScreen({
    super.key,
    required this.bankName,
    required this.accountName,
    required this.amount,
    required this.time,
    this.isServiceTransaction = false,
    this.isSimulation = false,
    this.providerReference,
  });

  @override
  Widget build(BuildContext context) {
    final amountText = NumberFormat.decimalPattern('vi').format(amount);

    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isSimulation
                            ? 'Chuyển tiền mô phỏng thành công'
                            : 'Giao dịch thành công',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$amountText VND',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      if (isSimulation) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Đây là giao dịch mô phỏng. Số dư ví AnPay đã bị trừ trong database, nhưng ngân hàng bên ngoài không nhận tiền thật.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      _infoRow('Thời gian giao dịch', time),
                      if (isServiceTransaction)
                        _infoRow('Dịch vụ', accountName)
                      else ...[
                        _infoRow(
                          isSimulation ? 'Ngân hàng nhận' : 'Ngân hàng liên kết',
                          bankName,
                        ),
                        _infoRow('Tên tài khoản nhận', accountName),
                      ],
                      _infoRow('Số tiền', '$amountText VND'),
                      _infoRow('Phí giao dịch', 'Miễn phí'),
                      if (providerReference != null &&
                          providerReference!.trim().isNotEmpty)
                        _infoRow('Mã mô phỏng', providerReference!),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        AppLogger.action(
                          'TRANSACTION RESULT home pressed',
                          {'amount': amount, 'simulation': isSimulation},
                        );
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const TabbarScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Trang chủ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        AppLogger.action(
                          'TRANSACTION RESULT transfer again pressed',
                          {'amount': amount, 'simulation': isSimulation},
                        );
                        context.go('/transfer');
                      },
                      child: const Text(
                        'Tiếp tục chuyển tiền',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
