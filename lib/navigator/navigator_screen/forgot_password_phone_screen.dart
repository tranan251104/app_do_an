import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPhoneScreen extends StatefulWidget {
  const ForgotPasswordPhoneScreen({super.key});

  @override
  State<ForgotPasswordPhoneScreen> createState() => _ForgotPasswordPhoneScreenState();
}

class _ForgotPasswordPhoneScreenState extends State<ForgotPasswordPhoneScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _verificationId;
  

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10 || !phone.startsWith("0")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại phải 10 số, bắt đầu bằng 0")),
      );
      return;
    }
    final formattedPhone = "+84${phone.substring(1)}";

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: ${e.message}")),
        );
      },
      codeSent: (verId, _) {
        setState(() => _verificationId = verId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP đã được gửi!")),
        );
      },
      codeAutoRetrievalTimeout: (verId) => _verificationId = verId,
    );
  }

  Future<void> _resetPassword() async {
    if (_verificationId == null) return;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      // ✅ Lưu mật khẩu mới vào Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).update({
          "password": _newPasswordController.text.trim(), // ⚠️ nên hash
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật mật khẩu thành công!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quên mật khẩu (SĐT)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Số điện thoại")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _sendOtp, child: const Text("Gửi OTP")),

            if (_verificationId != null) ...[
              TextField(controller: _otpController, decoration: const InputDecoration(labelText: "OTP")),
              TextField(controller: _newPasswordController, decoration: const InputDecoration(labelText: "Mật khẩu mới")),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _resetPassword, child: const Text("Đổi mật khẩu")),
            ],
          ],
        ),
      ),
    );
  }
}
