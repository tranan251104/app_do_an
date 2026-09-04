import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/navigator_screen/forgot_password_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String identifier;
  final bool isPhoneMode;
  final String? verificationId;
  final PasswordFlowMode mode;

  const OtpVerifyScreen({
    super.key,
    required this.identifier,
    this.isPhoneMode = false,
    this.verificationId,
    this.mode = PasswordFlowMode.forgot,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String _enteredOtp = '';
  bool _loading = false;

  Future<void> _verifyOtp() async {
    AppLogger.action('AUTH OTP verify button pressed', {
      'otpLength': _enteredOtp.length,
    });
    if (_enteredOtp.length != 6) return;
    setState(() => _loading = true);
    try {
      if (widget.mode != PasswordFlowMode.forgot) {
        throw const ApiException(
          code: 'UNSUPPORTED_FLOW',
          message:
              'Đổi mật khẩu không cần OTP. Hãy nhập mật khẩu hiện tại trong mục Đổi mật khẩu.',
        );
      }
      final resetToken = await AppServices.auth.forgotPasswordVerify(
        widget.identifier,
        _enteredOtp,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(resetToken: resetToken),
        ),
      );
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận OTP')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 24),
            Text(
              'Mã OTP đã gửi đến ${widget.identifier}',
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
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _enteredOtp.length == 6 && !_loading
                  ? _verifyOtp
                  : null,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('XÁC NHẬN'),
            ),
          ],
        ),
      ),
    );
  }
}
