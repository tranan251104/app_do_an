import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpConfirmScreen extends StatefulWidget {
  final String email;
  final PaymentAccount account;
  final int amount;

  const OtpConfirmScreen({
    super.key,
    required this.email,
    required this.account,
    required this.amount,
  });

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
            const SnackBar(content: Text("❌ Sai mã OTP, vui lòng thử lại")),
          );
        }
        return;
      }
      await _handleSuccessTransaction(widget.amount);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSuccessTransaction(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final nowFormatted = DateFormat("HH:mm dd/MM/yyyy").format(DateTime.now());
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    int senderNewBalance = 0;
    String? receiverEmail;
    int receiverNewBalance = 0;

    try {
      await db.runTransaction((tx) async {
        // 1. Cập nhật số dư người chuyển
        final senderDoc = await tx.get(db.collection('users').doc(user.uid));
        senderNewBalance = (senderDoc.data()?['balance'] ?? 0) - amount;
        tx.update(db.collection('users').doc(user.uid), {'balance': senderNewBalance});

        // 2. Nếu là chuyển nội bộ ANPAY, cập nhật số dư người nhận
        if (widget.account.provider.contains("ANPAY")) {
          final receiverDoc = await tx.get(db.collection('users').doc(widget.account.accountNumber));
          if (receiverDoc.exists) {
            receiverEmail = receiverDoc.data()?['email'];
            receiverNewBalance = (receiverDoc.data()?['balance'] ?? 0) + amount;
            tx.update(db.collection('users').doc(widget.account.accountNumber), {'balance': receiverNewBalance});
            
            // Lưu lịch sử cho người nhận
            tx.set(db.collection('users').doc(widget.account.accountNumber).collection('transactions').doc(), {
              'title': "Nhận tiền từ ${senderDoc.data()?['name'] ?? 'Người dùng ANPAY'}",
              'amount': amount,
              'createdAt': FieldValue.serverTimestamp(),
              'displayTime': nowFormatted,
            });
          }
        }
      });

      // Lưu lịch sử local & firestore cho người chuyển
      await db.collection('users').doc(user.uid).collection('transactions').add({
        'title': "Chuyển tiền tới ${widget.account.name}",
        'amount': -amount,
        'createdAt': FieldValue.serverTimestamp(),
        'displayTime': nowFormatted,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("wallet_balance", senderNewBalance);

      // --- GỬI THÔNG BÁO & EMAIL CHO NGƯỜI CHUYỂN ---
      await NotificationService.showNotification(
        id: 1,
        title: "Biến động số dư",
        body: "TK ANPAY vừa trừ ${currencyFormat.format(amount)}. Số dư: ${currencyFormat.format(senderNewBalance)}",
      );

      await OtpService.sendTransactionEmail(
        email: widget.email,
        type: "transfer",
        amount: amount,
        balance: senderNewBalance,
        note: "Chuyển tiền tới ${widget.account.name}",
        time: nowFormatted,
      );

      // --- GỬI EMAIL CHO NGƯỜI NHẬN (NẾU CÓ) ---
      if (receiverEmail != null) {
        await OtpService.sendTransactionEmail(
          email: receiverEmail!,
          type: "receive",
          amount: amount,
          balance: receiverNewBalance,
          note: "Nhận tiền từ người dùng ANPAY",
          time: nowFormatted,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TransactionResultScreen(
        bankName: widget.account.provider,
        accountName: widget.account.name,
        amount: amount,
        time: nowFormatted,
        isServiceTransaction: widget.account.isService,
      )));

    } catch (e) {
      throw Exception("Giao dịch thất bại: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Nhập mã xác thực để hoàn tất chuyển tiền", textAlign: TextAlign.center),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context, length: 6,
              onChanged: (v) => _enteredOtp = v,
              pinTheme: PinTheme(shape: PinCodeFieldShape.box, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
              child: _loading ? const CircularProgressIndicator() : const Text("XÁC NHẬN CHUYỂN TIỀN"),
            ),
          ],
        ),
      ),
    );
  }
}
