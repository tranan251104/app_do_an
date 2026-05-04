import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verify_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';

enum PasswordFlowMode { forgot, change }

class ForgotPasswordScreen extends StatefulWidget {
  final PasswordFlowMode mode;

  const ForgotPasswordScreen({
    super.key,
    this.mode = PasswordFlowMode.forgot,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();
  bool _loading = false;
  bool _isPhoneMode = false;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) return;

    setState(() => _loading = true);
    try {
      if (_isPhoneMode) {
        // Gửi OTP qua Số điện thoại (Firebase)
        final formattedPhone = identifier.startsWith("+84") 
            ? identifier 
            : "+84${identifier.startsWith('0') ? identifier.substring(1) : identifier}";

        await _auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Có thể tự động đăng nhập nếu Firebase hỗ trợ tự động xác thực
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Lỗi: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("OTP đã được gửi tới SĐT".tr())),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerifyScreen(
                  identifier: identifier,
                  isPhoneMode: true,
                  verificationId: verificationId,
                  mode: widget.mode,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } else {
        // Gửi OTP qua Email (OtpService)
        await OtpService.sendOtp(identifier);

        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP đã được gửi tới email".tr())),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerifyScreen(
              identifier: identifier,
              isPhoneMode: false,
              mode: widget.mode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == PasswordFlowMode.forgot ? "Quên mật khẩu".tr() : "Xác thực tài khoản".tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.lock_reset, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                _isPhoneMode ? "Nhập số điện thoại để nhận mã OTP".tr() : "Nhập địa chỉ email để nhận mã OTP".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
        
              buildInput(
                icon: Icon(_isPhoneMode ? Icons.phone : Icons.email_outlined),
                hint: _isPhoneMode ? "Số điện thoại".tr() : "Email".tr(),
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
                    : Text("GỬI MÃ XÁC THỰC".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
        
              const SizedBox(height: 40),
              SocialButton(
                mode: "login",
                isPhonePage: _isPhoneMode,
                onToggleMode: () {
                  setState(() {
                    _isPhoneMode = !_isPhoneMode;
                    _identifierController.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
