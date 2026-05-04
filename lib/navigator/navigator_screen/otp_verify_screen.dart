import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'change_password_screen.dart';
import 'reset_password_screen.dart';
import 'forgot_password_screen.dart';
import 'package:app_do_an/navigator/service/otp.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String identifier; // Email hoặc Số điện thoại
  final bool isPhoneMode;
  final String? verificationId; // Bắt buộc nếu là Phone Mode
  final PasswordFlowMode mode;

  const OtpVerifyScreen({
    super.key,
    required this.identifier,
    this.isPhoneMode = false,
    this.verificationId,
    this.mode = PasswordFlowMode.forgot,
  }) : assert(!isPhoneMode || verificationId != null, "Phone mode requires verificationId");

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String _enteredOtp = "";
  bool _loading = false;

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);

    try {
      bool isSuccess = false;

      if (widget.isPhoneMode) {
        // Xác thực qua Firebase cho Số điện thoại
        final credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId!,
          smsCode: _enteredOtp,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        isSuccess = true;
      } else {
        // Xác thực qua OtpService cho Email
        isSuccess = await OtpService.verifyOtp(widget.identifier, _enteredOtp);
      }

      if (isSuccess) {
        if (!mounted) return;
        if (widget.mode == PasswordFlowMode.forgot) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: widget.identifier),
            ),
          );
        } else if (widget.mode == PasswordFlowMode.change) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChangePasswordScreen(email: widget.identifier),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Sai OTP, vui lòng thử lại")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.security, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            Text(
              "Mã OTP đã gửi đến ${widget.identifier}",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            PinCodeTextField(
              appContext: context,
              length: 6,
              autoFocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _enteredOtp = value),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 55,
                fieldWidth: 45,
                activeFillColor: Colors.white,
                activeColor: Colors.deepPurpleAccent,
                selectedColor: Colors.deepPurple,
                inactiveColor: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _enteredOtp.length == 6 && !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
