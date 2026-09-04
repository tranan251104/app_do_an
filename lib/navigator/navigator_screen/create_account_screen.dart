import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/auth/data/email_otp_models.dart';
import 'package:app_do_an/features/auth/data/phone_otp_models.dart';
import 'package:app_do_an/navigator/navigator_screen/backend_phone_otp_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/email_registration_otp_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    AppLogger.action('REGISTER button pressed');
    final input = _identifierController.text.trim();
    final password = _passwordController.text;
    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    if (input.isEmpty || password.isEmpty || fullName.isEmpty) {
      _show('Vui lòng điền đầy đủ thông tin'.tr());
      return;
    }
    if (password.length < 8) {
      _show('Mật khẩu phải có ít nhất 8 ký tự');
      return;
    }
    if (!_isPhoneMode &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input)) {
      _show('Email không hợp lệ');
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? normalizedPhone;
      String? registeredEmail;
      if (_isPhoneMode) {
        normalizedPhone = normalizeVietnamesePhone(input);
        final result = await Navigator.push<PhoneOtpLoginResult>(
          context,
          MaterialPageRoute(
            builder: (_) => BackendPhoneOtpScreen(
              phoneNumber: normalizedPhone!,
              registrationFullName: fullName,
              registrationPassword: password,
            ),
          ),
        );
        if (result == null) return;
        normalizedPhone = result.phoneNumber;
      } else {
        final result = await Navigator.push<EmailOtpRegistrationResult>(
          context,
          MaterialPageRoute(
            builder: (_) => EmailRegistrationOtpScreen(
              email: input,
              registrationFullName: fullName,
              registrationPassword: password,
            ),
          ),
        );
        if (result == null) return;
        registeredEmail = result.email;
      }
      await NotificationService.registerCurrentDevice(source: 'register');

      // Keep non-sensitive display preferences for legacy UI only.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', fullName);
      await prefs.setString('login_method', _isPhoneMode ? 'phone' : 'email');
      if (_isPhoneMode) {
        await prefs.setString('user_phone', normalizedPhone!);
        await prefs.remove('user_email');
      } else {
        await prefs.setString('user_email', registeredEmail!);
        await prefs.remove('user_phone');
      }

      if (!mounted) return;
      context.go('/profile');
    } on ApiException catch (e) {
      _show(e.message);
    } catch (e) {
      _show('Không thể đăng ký: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            children: [
              const Text(
                'AnPay',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isPhoneMode
                    ? 'Create an account (Phone)'.tr()
                    : 'Create an account (Email)'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              buildInput(
                icon: const Icon(Icons.person),
                hint: 'First name',
                controller: _firstNameController,
              ),
              buildInput(
                icon: const Icon(Icons.person_outline),
                hint: 'Last name',
                controller: _lastNameController,
              ),
              const SizedBox(height: 16),
              buildInput(
                icon: Icon(_isPhoneMode ? Icons.phone : Icons.email_outlined),
                hint: _isPhoneMode ? 'Số điện thoại'.tr() : 'Email'.tr(),
                controller: _identifierController,
                keyboardType: _isPhoneMode
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
              ),
              buildInput(
                icon: const Icon(Icons.lock_outline),
                hint: 'Mật khẩu'.tr(),
                controller: _passwordController,
                obscure: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'ĐĂNG KÝ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              SocialButton(
                mode: 'register',
                isPhonePage: _isPhoneMode,
                onToggleMode: () {
                  setState(() {
                    _isPhoneMode = !_isPhoneMode;
                    _identifierController.clear();
                  });
                },
              ),
              const SizedBox(height: 32),
              RichText(
                text: TextSpan(
                  text: 'Already have an account? '.tr(),
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Login'.tr(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const WelcomeScreen(fromLogin: true),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
