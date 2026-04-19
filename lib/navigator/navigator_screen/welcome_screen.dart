import 'package:app_do_an/navigator/navigator_screen/create_account_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/navigator_helper.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:app_do_an/navigator/navigator_screen/forgot_password_email_screen.dart';


class WelcomeScreen extends StatefulWidget {
  final bool fromLogin; // phân biệt luồng
  const WelcomeScreen({super.key, required this.fromLogin});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm xử lý login
  Future<void> _handleLogin() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vui lòng nhập email và mật khẩu".tr())),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // tắt loading

    // ✅ Lưu SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("login_method", "email");
    await prefs.setString("user_email", _emailController.text.trim());
    await prefs.remove("user_phone"); // xoá phone nếu có

    /*NavigationHelper.pushCupertino(
      context,
      const MainScreen(fromLogin: true),
    );*/
    context.go('/main');
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'Email không hợp lệ.';
        break;
      case 'user-disabled':
        message = 'Tài khoản đã bị vô hiệu hóa.';
        break;
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản này.';
        break;
      case 'wrong-password':
        message = 'Sai mật khẩu.';
        break;
      case 'network-request-failed':
        message = 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
        break;
      default:
        message = e.message ?? 'Có lỗi xảy ra.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.tr())),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Hey there,".tr(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400)
                        ),
                        Text("Welcome back".tr(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins")
                        ),
                        const SizedBox(height: 20),
                        buildInput(
                            icon: const Icon(Icons.email),
                            hint: "Email".tr(),
                            controller: _emailController
                        ),
                        const SizedBox(height: 10),
                        buildInput(
                            icon: const Icon(Icons.lock),
                            hint: "Password".tr(),
                            controller: _passwordController,
                            obscure: true
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordEmailScreen(mode: PasswordFlowMode.forgot),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot your password?".tr(),
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const Spacer(),
                        // nút Login
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _handleLogin,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.login, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text("Login".tr(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: "Poppins")),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Expanded(
                                child:
                                    Divider(thickness: 1, color: Colors.grey)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(" Or ".tr(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter")),
                            ),
                            const Expanded(
                                child:
                                    Divider(thickness: 1, color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 3),
                        SocialButton(mode: "login"),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Don't have an account yet? ".tr(),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "Register".tr(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w400,
                                        color: Colors.pinkAccent),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        NavigationHelper.pushCupertino(context,
                                            CreateAccountScreen());
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}




