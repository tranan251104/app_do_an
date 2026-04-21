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
      final ok = await OtpService.verifyOtp(widget.email, _enteredOtp);

      if (!ok) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Sai OTP, vui lòng thử lại")),
          );
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Người dùng chưa đăng nhập");

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      // 🔹 1. Trừ tiền trong Firestore (Sửa field 'balance' cho khớp với HomeTabbar)
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) throw Exception("Không tìm thấy user trên Firestore");

        // Đọc trường 'balance' thay vì 'wallet_balance'
        int currentBalance = (snapshot.data() as Map<String, dynamic>)['balance'] ?? 0;
        
        if (currentBalance < widget.amount) throw Exception("Số dư không đủ");

        transaction.update(userDoc, {'balance': currentBalance - widget.amount});
      });

      // 🔹 2. Cập nhật SharedPreferences (Local cache)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("wallet_balance", (prefs.getInt("wallet_balance") ?? 0) - widget.amount);

      // 🔹 3. Chuẩn bị dữ liệu lịch sử
      final nowFormatted = DateFormat("HH:mm dd/MM/yyyy").format(DateTime.now());
      String title = widget.account1 != null 
          ? "Chuyển tiền cho ${widget.account1!.ownerName}"
          : "Thanh toán ${widget.account2!.serviceName}";

      // 🔹 4. Lưu lịch sử vào Firestore (Để ScheduleTabbar tự động cập nhật qua Stream)
      await userDoc.collection('transactions').add({
        'title': title,
        'amount': -widget.amount,
        'createdAt': FieldValue.serverTimestamp(),
        'displayTime': nowFormatted,
      });

      // 🔹 5. Lưu lịch sử vào Local
      await TransactionStorage.addTransaction(
        model.Transaction(
          title: title,
          amount: -widget.amount,
          time: nowFormatted,
        ),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            bankName: widget.account1?.bankName ?? "",
            accountName: widget.account1?.ownerName ?? "${widget.account2!.serviceName}",
            amount: widget.amount,
            time: nowFormatted,
            isServiceTransaction: widget.account2 != null,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận OTP"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 16),
            const Text("Mã OTP đã được gửi đến email", style: TextStyle(color: Colors.grey)),
            Text(widget.email, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              onChanged: (v) => _enteredOtp = v,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 45,
                activeColor: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text("XÁC NHẬN THANH TOÁN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
