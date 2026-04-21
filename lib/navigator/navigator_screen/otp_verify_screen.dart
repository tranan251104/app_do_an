import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'change_password_screen.dart';
import 'reset_password_screen.dart';
import 'forgot_password_screen.dart';
import 'package:app_do_an/navigator/service/otp.dart';


class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final PasswordFlowMode mode;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    this.mode = PasswordFlowMode.forgot,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String _enteredOtp = "";
  bool _loading = false;

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);

    final ok = await OtpService.verifyOtp(widget.email, _enteredOtp);

    setState(() => _loading = false);

    if (ok) {
      if (widget.mode == PasswordFlowMode.forgot) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      } else if (widget.mode == PasswordFlowMode.change) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(email: widget.email),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Sai OTP, vui lòng thử lại")),
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

            // Ô nhập OTP
            PinCodeTextField(
              appContext: context,
              length: 6,
              autoFocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _enteredOtp = value;
                });
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

            // Nút xác nhận
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

