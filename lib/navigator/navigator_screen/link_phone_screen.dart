import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/auth/data/firebase_phone_auth_service.dart';
import 'package:app_do_an/navigator/navigator_screen/phone_otp_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:flutter/material.dart';

class LinkPhoneScreen extends StatefulWidget {
  final String initialPhone;

  const LinkPhoneScreen({super.key, this.initialPhone = ''});

  @override
  State<LinkPhoneScreen> createState() => _LinkPhoneScreenState();
}

class _LinkPhoneScreenState extends State<LinkPhoneScreen> {
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _linkPhone() async {
    final rawPhone = _phoneController.text.trim();
    final currentPassword = _passwordController.text;
    if (rawPhone.isEmpty || currentPassword.isEmpty) {
      _show('Vui lòng nhập số điện thoại và mật khẩu hiện tại.');
      return;
    }

    setState(() => _loading = true);
    try {
      final normalizedPhone = FirebasePhoneAuthService.normalizeVietnamesePhone(
        rawPhone,
      );
      final firebaseIdToken = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => PhoneOtpScreen(phoneNumber: normalizedPhone),
        ),
      );
      if (firebaseIdToken == null) return;

      final result = await AppServices.auth.linkPhone(
        firebaseIdToken: firebaseIdToken,
        currentPassword: currentPassword,
      );
      if (!mounted) return;
      AppLogger.success('LINK_PHONE_UI', 'Phone linked from profile');
      Navigator.of(context).pop(result['phone']?.toString() ?? normalizedPhone);
    } on PhoneAuthFailure catch (error) {
      _show(error.message);
    } on ApiException catch (error) {
      await AppServices.phoneAuth.signOut();
      _show(error.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'LINK_PHONE_UI',
        'Unexpected link-phone failure',
        error: error,
        stackTrace: stackTrace,
      );
      _show('Không thể liên kết số điện thoại. Vui lòng thử lại.');
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
      appBar: AppBar(title: const Text('Liên kết số điện thoại')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.phone_android,
                size: 72,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Số điện thoại sẽ được xác minh bằng SMS OTP. Mật khẩu hiện tại dùng để bảo vệ tài khoản AnPay.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              buildInput(
                icon: const Icon(Icons.phone_outlined),
                hint: 'Số điện thoại',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              buildInput(
                icon: const Icon(Icons.lock_outline),
                hint: 'Mật khẩu hiện tại',
                controller: _passwordController,
                obscure: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _linkPhone,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('GỬI OTP VÀ LIÊN KẾT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
