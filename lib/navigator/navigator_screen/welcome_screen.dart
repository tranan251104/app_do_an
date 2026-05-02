import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:app_do_an/navigator/navigator_screen/create_account_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:app_do_an/navigator/navigator_screen/forgot_password_screen.dart'; // 🔹 Import file đã gộp

class WelcomeScreen extends StatefulWidget {
  final bool fromLogin;
  const WelcomeScreen({super.key, required this.fromLogin});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneMode = false; // 🔹 Mặc định là Email (false)

  Future<void> _handleLogin() async {
    final input = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng điền đầy đủ thông tin".tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!_isPhoneMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: input, password: password);
      } else {
        final query = await FirebaseFirestore.instance.collection('users').where('phone', isEqualTo: input).limit(1).get();
        if (query.docs.isEmpty || query.docs.first.data()['password'] != password) {
          throw Exception("Sai số điện thoại hoặc mật khẩu");
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("login_method", _isPhoneMode ? "phone" : "email");
      await prefs.setString(_isPhoneMode ? "user_phone" : "user_email", input);
      await prefs.setBool('isRegistered', true); // 🔹 Đánh dấu đã có tài khoản (đã đăng nhập thành công)

      if (!mounted) return;
      context.go('/main');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              const Text("AnPay", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 10),
              Text(_isPhoneMode ? "Login with Phone".tr() : "Login with Email".tr(), 
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 50),
              
              buildInput(
                icon: Icon(_isPhoneMode ? Icons.phone : Icons.email_outlined),
                hint: _isPhoneMode ? "Số điện thoại".tr() : "Email".tr(),
                controller: _identifierController,
                keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              buildInput(
                icon: const Icon(Icons.lock_outline),
                hint: "Mật khẩu".tr(),
                controller: _passwordController,
                obscure: true,
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // 🔹 Dẫn về màn hình gộp chung
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen(mode: PasswordFlowMode.forgot))
                    );
                  },
                  child: Text("Forgot password?".tr(), style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                ),
              ),
        
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text("ĐĂNG NHẬP", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
              
              const SizedBox(height: 40),
              RichText(
                text: TextSpan(
                  text: "Don't have an account? ".tr(),
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Register".tr(),
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
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
