import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/auth/data/phone_otp_models.dart';
import 'package:app_do_an/navigator/navigator_screen/create_account_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/forgot_password_screen.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final bool fromLogin;

  const WelcomeScreen({super.key, required this.fromLogin});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPhoneMode = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    AppLogger.action('LOGIN button pressed', {
      'mode': _isPhoneMode ? 'phone' : 'email',
    });
    final input = _identifierController.text.trim();
    final password = _passwordController.text;

    if (input.isEmpty || password.isEmpty) {
      AppLogger.warning('LOGIN_UI', 'Login blocked by validation', {
        'identifierEmpty': input.isEmpty,
        'passwordEmpty': password.isEmpty,
      });
      _show('Vui lòng điền đầy đủ thông tin'.tr());
      return;
    }

    setState(() => _isLoading = true);
    AppLogger.repo('LOGIN_UI', 'Submitting login to AuthRepository', {
      'identifier': AppLogger.mask(input),
    });
    try {
      String? normalizedPhone;
      if (_isPhoneMode) {
        normalizedPhone = normalizeVietnamesePhone(input);
      }
      await AppServices.auth.login(
        identifier: normalizedPhone ?? input,
        password: password,
      );
      AppLogger.success(
        'LOGIN_UI',
        'Login completed; syncing FCM device token',
      );
      await NotificationService.registerCurrentDevice(source: 'login');
      AppLogger.success('LOGIN_UI', 'Post-login push-device sync finished');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('login_method', _isPhoneMode ? 'phone' : 'email');
      if (_isPhoneMode) {
        await prefs.setString('user_phone', normalizedPhone!);
        await prefs.remove('user_email');
      } else {
        await prefs.setString('user_email', input);
        await prefs.remove('user_phone');
      }

      final setup = await AppServices.wallet.accountNumberStatus();
      final walletCreated = setup['walletCreated'] == true;
      AppLogger.app('Post-login wallet setup check', {
        'walletCreated': walletCreated,
      });

      if (!mounted) return;
      if (!walletCreated) {
        // Recovery path: if registration was interrupted before the user chose
        // an AnPay account number, finish that setup after this valid login.
        context.go('/wallet-number?finish=main');
      } else {
        context.go('/main?fromLogin=true');
      }
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'LOGIN_UI',
        'Login failed with ApiException',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'status': e.statusCode ?? 'NO_RESPONSE'},
      );
      _show(e.message);
    } catch (e, stackTrace) {
      AppLogger.error(
        'LOGIN_UI',
        'Login failed unexpectedly',
        error: e,
        stackTrace: stackTrace,
      );
      _show('Không thể đăng nhập: $e');
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
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
              const SizedBox(height: 10),
              Text(
                _isPhoneMode
                    ? 'Login with Phone'.tr()
                    : 'Login with Email'.tr(),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              buildInput(
                icon: Icon(_isPhoneMode ? Icons.phone : Icons.email_outlined),
                hint: _isPhoneMode ? 'Số điện thoại'.tr() : 'Email'.tr(),
                controller: _identifierController,
                keyboardType: _isPhoneMode
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              buildInput(
                icon: const Icon(Icons.lock_outline),
                hint: 'Mật khẩu'.tr(),
                controller: _passwordController,
                obscure: true,
              ),
              if (!_isPhoneMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(
                          mode: PasswordFlowMode.forgot,
                        ),
                      ),
                    ),
                    child: Text(
                      'Forgot password?'.tr(),
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
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
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
              SocialButton(
                mode: 'login',
                isPhonePage: _isPhoneMode,
                onToggleMode: () {
                  AppLogger.action('Toggle login mode', {
                    'to': _isPhoneMode ? 'email' : 'phone',
                  });
                  setState(() {
                    _isPhoneMode = !_isPhoneMode;
                    _identifierController.clear();
                    _passwordController.clear();
                  });
                },
              ),
              const SizedBox(height: 40),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ".tr(),
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Register'.tr(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountScreen(),
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
