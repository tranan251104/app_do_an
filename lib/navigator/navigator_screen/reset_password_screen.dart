// Man hinh dat lai mat khau sau khi nhap otp

import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/service/otp.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  bool _loading = false;

  /// 🔹 Validate mật khẩu theo rule
  String? _validatePassword(String value) {
    if (value.isEmpty) return "Vui lòng nhập mật khẩu";
    if (value.length < 8) return "Mật khẩu phải có ít nhất 8 ký tự";
    if (!RegExp(r'[a-z]').hasMatch(value)) return "Cần ít nhất 1 chữ thường";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Cần ít nhất 1 chữ hoa";
    if (!RegExp(r'[0-9]').hasMatch(value)) return "Cần ít nhất 1 chữ số";
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Cần ít nhất 1 ký tự đặc biệt";
    }
    return null;
  }

  Future<void> _resetPassword() async {
    final newPass = _passController.text.trim();

    // ✅ Kiểm tra mật khẩu trước khi gọi API
    final error = _validatePassword(newPass);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _loading = true);
    try {
      await OtpService.resetPassword(widget.email, newPass);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đặt lại mật khẩu thành công")),
      );

      Navigator.popUntil(context, (route) => route.isFirst); // về Login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt lại mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu mới",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _resetPassword,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Đặt lại mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}

