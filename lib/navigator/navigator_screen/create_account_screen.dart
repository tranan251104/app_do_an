// Man hinh dang ki tai khoan
import 'package:go_router/go_router.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/language_button.dart';
import 'package:app_do_an/navigator/navigator_widget/navigator_helper.dart';
import 'package:app_do_an/navigator/navigator_widget/social_button_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Regex email
  final _emailRegex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
      r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*$");

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return "Vui lòng nhập email".tr();
    if (!_emailRegex.hasMatch(value.trim())) return "Email không hợp lệ".tr();
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return "Vui lòng nhập mật khẩu".tr();
    if (value.length < 8) return "Mật khẩu phải có ít nhất 8 ký tự".tr();
    if (!RegExp(r'[a-z]').hasMatch(value)) return "Cần ít nhất 1 chữ thường".tr();
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Cần ít nhất 1 chữ hoa".tr();
    if (!RegExp(r'[0-9]').hasMatch(value)) return "Cần ít nhất 1 chữ số".tr();
    if (!RegExp(r'[!@#\$%^&*(),.?\":{}|<>]').hasMatch(value)) {
      return "Cần ít nhất 1 ký tự đặc biệt".tr();
    }
    return null;
  }

  Future<void> _handleCreateAccount() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin".tr())),
      );
      return;
    }

    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    final passError = _validatePassword(_passwordController.text);
    if (passError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(passError)));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final User? user = userCredential.user;

      if (user != null) {
        final fullName =
            "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

        await _firestore.collection('users').doc(user.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'fullName': fullName,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 🔹 Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isRegistered', true);
        await prefs.setString('name', fullName);
        await prefs.setString('email', _emailController.text.trim());

        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng ký thành công".tr())),
        );

        /*Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => const ProfileEmailScreen()),
        );*/
        context.go('/profile');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu.';
          break;
        case 'email-already-in-use':
          message = 'Email này đã được sử dụng.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'operation-not-allowed':
          message =
              'Đăng ký bằng Email/Password chưa được bật trên Firebase.';
          break;
        case 'network-request-failed':
          message = 'Lỗi mạng. Vui lòng kiểm tra kết nối.';
          break;
        default:
          message = e.message ?? 'Có lỗi đã xảy ra.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: GestureDetector(
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
                      padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        // Header
                          SizedBox(
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Hey there,".tr(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins"
                                        )
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Create an account".tr(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        fontFamily: "Poppins"
                                      )
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: LanguageButton(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // 🔹 Input fields
                          buildInput(
                            icon: const Icon(Icons.person_outline),
                            hint: "First name".tr(),
                            controller: _firstNameController
                          ),
                          buildInput(
                            icon: const Icon(Icons.person_outline),
                            hint: "Last name".tr(),
                            controller: _lastNameController
                          ),
                          buildInput(
                            icon: const Icon(Icons.email_outlined),
                            hint: "Email".tr(),
                            controller: _emailController
                          ),
                          buildInput(
                            icon: const Icon(Icons.lock_outline),
                            hint: "Password".tr(),
                            controller: _passwordController,
                            obscure: true
                          ),
                          const SizedBox(height: 15),

                          // 🔹 Terms & Privacy
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(value: false, onChanged: (value) {}),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: "By continuing you accept our ".tr(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontFamily: "Poppins"
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Privacy Policy".tr(),
                                        style: const TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.black)
                                      ),
                                      const TextSpan(text: " and "),
                                      TextSpan(
                                        text: "Terms of Use".tr(),
                                        style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.black
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // 🔹 Register button
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _handleCreateAccount,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Register".tr(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "Poppins"
                                    )
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(thickness: 1, color: Colors.grey)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text("Or".tr(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400)),
                                ),
                              const Expanded(
                                child: Divider(thickness: 1, color: Colors.grey)
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // 🔹 Social login
                          SocialButton(mode: "register"),
                          const SizedBox(height: 25),

                          // 🔹 Login redirect
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "Already have an account? ".tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Login".tr(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.pinkAccent
                                      ),
                                      recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setBool("isRegistered", true);
                                        NavigationHelper.pushCupertino(
                                          context,
                                          const WelcomeScreen(fromLogin: true)
                                        );
                                      },
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              );
            },
          ),
        ),
      ),
    );
  }
}



