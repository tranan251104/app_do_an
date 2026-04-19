import 'package:flutter/material.dart';

class LearningBillScreen extends StatelessWidget {
  const LearningBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán tiền học phí"),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text(
          "Màn hình nhập thông tin & thanh toán hóa đơn học phí",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}