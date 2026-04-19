import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:app_do_an/navigator/model/bankAccount1.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:app_do_an/navigator/model/transaction.dart';
import 'package:app_do_an/navigator/service/transaction_storage.dart';
import 'package:intl/intl.dart';

class OtpConfirmScreen extends StatefulWidget {
  final String email;
  final BankAccount1? account1; // ✅ chuyển tiền
  final BankAccount2? account2; // ✅ dịch vụ
  final int amount;

  const OtpConfirmScreen({
    super.key,
    required this.email,
    this.account1,
    this.account2,
    required this.amount,
  }) : assert(account1 != null || account2 != null,
            "Phải truyền account1 hoặc account2");

  @override
  State<OtpConfirmScreen> createState() => _OtpConfirmScreenState();
}

class _OtpConfirmScreenState extends State<OtpConfirmScreen> {
  String _enteredOtp = "";
  bool _loading = false;

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);

    final ok = await OtpService.verifyOtp(widget.email, _enteredOtp);

    setState(() => _loading = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sai OTP, vui lòng thử lại")),
      );
      return;
    }

    // 🔹 Trừ tiền trong ví
    final prefs = await SharedPreferences.getInstance();
    int balance = prefs.getInt("wallet_balance") ?? 0;
    final newBalance = balance - widget.amount;
    await prefs.setInt("wallet_balance", newBalance);

    // 🔹 Lưu lịch sử giao dịch
    final now = DateFormat("HH:mm dd/MM").format(DateTime.now());

    if (widget.account1 != null) {
      // 👉 Trường hợp chuyển tiền (BankAccount1)
      final acc = widget.account1!;
      final title = "Chuyển tiền cho ${acc.ownerName}";

      await TransactionStorage.addTransaction(
        Transaction(
          title: title,
          amount: -widget.amount,
          time: now,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            bankName: acc.bankName,
            accountName: acc.ownerName,
            amount: widget.amount,
            time: now,
            isServiceTransaction: false,
          ),
        ),
      );
    } else if (widget.account2 != null) {
      // 👉 Trường hợp dịch vụ (BankAccount2)
      final service = widget.account2!;
      final title = "${service.serviceName} - ${service.provider}";

      await TransactionStorage.addTransaction(
        Transaction(
          title: "Thanh toán dịch vụ $title",
          amount: -widget.amount,
          time: now,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            bankName: "", // dịch vụ nên để trống
            accountName: "${service.serviceName} - ${service.provider}",
            amount: widget.amount,
            time: now,
            isServiceTransaction: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận OTP"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Mã OTP đã gửi đến ${widget.email}",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 🔹 Ô nhập OTP
            PinCodeTextField(
              appContext: context,
              length: 6,
              autoFocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => _enteredOtp = value);
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Nút xác nhận
            ElevatedButton(
              onPressed:
                  _enteredOtp.length == 6 && !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("XÁC NHẬN"),
            ),
          ],
        ),
      ),
    );
  }
}
