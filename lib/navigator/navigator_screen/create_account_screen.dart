import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';

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
    final input = _identifierController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = "${_firstNameController.text} ${_lastNameController.text}";

    if (input.isEmpty || password.isEmpty || _firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng điền đầy đủ thông tin".tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!_isPhoneMode) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: input, password: password);
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'fullName': fullName,
          'email': input,
          'balance': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Đối với chế độ Phone, tạm thời giả lập hoặc xử lý theo logic Firebase Auth Phone nếu có
        await FirebaseFirestore.instance.collection('users').add({
          'fullName': fullName,
          'phone': input,
          'password': password,
          'balance': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("name", fullName);
      await prefs.setString("login_method", _isPhoneMode ? "phone" : "email");
      if (_isPhoneMode) {
        await prefs.setString("user_phone", input);
      } else {
        await prefs.setString("user_email", input);
      }
      
      if (!mounted) return;
      
      // 🔹 Thay đổi: Đi đến màn hình Profile để cập nhật thông tin thay vì vào thẳng Main
      context.go('/profile');

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            children: [
              const Text("AnPay", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 4),
              Text(_isPhoneMode ? "Create an account (Phone)".tr() : "Create an account (Email)".tr(), 
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 40),
              
              buildInput(icon: const Icon(Icons.person), hint: "First name", controller: _firstNameController),
              buildInput(icon: const Icon(Icons.person_outline), hint: "Last name", controller: _lastNameController),
        
              const SizedBox(height: 16),
              buildInput(
                icon: Icon(_isPhoneMode ? Icons.phone : Icons.email_outlined),
                hint: _isPhoneMode ? "Số điện thoại".tr() : "Email".tr(),
                controller: _identifierController,
                keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
              ),
              buildInput(icon: const Icon(Icons.lock_outline), hint: "Mật khẩu".tr(), controller: _passwordController, obscure: true),
        
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, 
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text("ĐĂNG KÝ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              
              const SizedBox(height: 30),
              SocialButton(
                mode: "register",
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
                  text: "Already have an account? ".tr(),
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Login".tr(),
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WelcomeScreen(fromLogin: true))),
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
