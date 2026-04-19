import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'otp_verify_screen.dart';

enum PasswordFlowMode { forgot, change }

class ForgotPasswordEmailScreen extends StatefulWidget {
  final PasswordFlowMode mode;

  const ForgotPasswordEmailScreen({
    super.key,
    this.mode = PasswordFlowMode.forgot,
  });

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    try {
      await OtpService.sendOtp(_emailController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📧 OTP đã được gửi tới email")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            email: _emailController.text.trim(),
            mode: widget.mode,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == PasswordFlowMode.forgot
            ? "Quên mật khẩu"
            : "Xác thực email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _sendOtp,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Gửi OTP"),
            ),
          ],
        ),
      ),
    );
  }
}

