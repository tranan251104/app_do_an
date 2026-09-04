import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/navigator_screen/otp_verify_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum PasswordFlowMode { forgot, change }

class ForgotPasswordScreen extends StatefulWidget {
  final PasswordFlowMode mode;

  const ForgotPasswordScreen({super.key, this.mode = PasswordFlowMode.forgot});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  bool _loading = false;
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    AppLogger.action('FORGOT PASSWORD send OTP pressed');
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) return;

    if (_isPhoneMode) {
      _show('Backend hiện chỉ gửi OTP khôi phục mật khẩu qua email. Hãy dùng email của tài khoản.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AppServices.auth.forgotPasswordRequest(identifier);
      if (!mounted) return;
      _show('OTP đã được gửi tới email'.tr());
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            identifier: identifier,
            mode: widget.mode,
          ),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == PasswordFlowMode.forgot ? 'Quên mật khẩu'.tr() : 'Xác thực tài khoản'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            Text(
              _isPhoneMode
                  ? 'Khôi phục qua số điện thoại chưa được backend hỗ trợ'.tr()
                  : 'Nhập địa chỉ email để nhận mã OTP'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            buildInput(
              icon: Icon(_isPhoneMode ? Icons.phone : Icons.email_outlined),
              hint: _isPhoneMode ? 'Số điện thoại'.tr() : 'Email'.tr(),
              controller: _identifierController,
              keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('GỬI MÃ XÁC THỰC'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 40),
            SocialButton(
              mode: 'login',
              isPhonePage: _isPhoneMode,
              onToggleMode: () => setState(() {
                _isPhoneMode = !_isPhoneMode;
                _identifierController.clear();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
