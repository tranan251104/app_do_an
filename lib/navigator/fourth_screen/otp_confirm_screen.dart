import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:app_do_an/navigator/model/bankAccount1.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:app_do_an/navigator/model/transaction.dart' as model;
import 'package:app_do_an/navigator/service/transaction_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpConfirmScreen extends StatefulWidget {
  final String email;
  final BankAccount1? account1; 
  final BankAccount2? account2; 
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
    if (_enteredOtp.length < 6) return;
    
    setState(() => _loading = true);

    try {
      // 1. Xác thực OTP (Vẫn giữ logic OTP để Demo quá trình bảo mật)
      final ok = await OtpService.verifyOtp(widget.email, _enteredOtp);

      if (!ok) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Sai mã OTP, vui lòng thử lại (Gợi ý: 123456)")),
          );
        }
        return;
      }

      // 2. GIẢ LẬP: Mô phỏng quá trình xử lý giao dịch ngân hàng
      await Future.delayed(const Duration(milliseconds: 2000));

      // 3. Hoàn tất cập nhật số dư và lịch sử trong App
      await _handleSuccessTransaction(widget.amount);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi hệ thống: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSuccessTransaction(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final nowFormatted = DateFormat("HH:mm dd/MM/yyyy").format(DateTime.now());
    
    // Cập nhật số dư Firestore
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(userDoc);
      int currentBalance = (snapshot.data()?['balance'] ?? 0) as int;
      tx.update(userDoc, {'balance': currentBalance - amount});
    });

    // Cập nhật SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    int localBalance = prefs.getInt("wallet_balance") ?? 0;
    await prefs.setInt("wallet_balance", localBalance - amount);

    String title = widget.account1 != null 
        ? "Chuyển tiền tới ${widget.account1!.ownerName}"
        : "Thanh toán dịch vụ ${widget.account2!.serviceName}";

    // Lưu lịch sử giao dịch vào Firestore
    await userDoc.collection('transactions').add({
      'title': title + " (Demo)", 
      'amount': -amount, 
      'createdAt': FieldValue.serverTimestamp(), 
      'displayTime': nowFormatted,
    });

    // Lưu vào storage local
    await TransactionStorage.addTransaction(
      model.Transaction(title: title, amount: -amount, time: nowFormatted),
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionResultScreen(
          bankName: widget.account1?.bankName ?? "Ví điện tử",
          accountName: widget.account1?.ownerName ?? "Hệ thống Demo",
          amount: amount,
          time: nowFormatted,
          isServiceTransaction: widget.account2 != null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận giao dịch"), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              "Mã OTP đã được gửi về Email của bạn.\nVui lòng nhập để hoàn tất giao dịch giả lập.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context, 
              length: 6, 
              keyboardType: TextInputType.number,
              onChanged: (v) => _enteredOtp = v,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box, 
                borderRadius: BorderRadius.circular(12), 
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.grey.shade300,
                selectedColor: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, 
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("XÁC NHẬN CHUYỂN TIỀN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Đây là môi trường thử nghiệm.\nKhông thực hiện giao dịch tài chính thật.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.redAccent, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
