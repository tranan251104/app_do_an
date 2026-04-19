import 'package:flutter/material.dart';

class HomeBillScreen extends StatelessWidget {
  const HomeBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán tiền nhà trọ"),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text(
          "Màn hình nhập thông tin & thanh toán hóa đơn tiền điện",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}