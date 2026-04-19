// Man hinh dang ki bang So dien thoai
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/language_button.dart';
import 'package:app_do_an/navigator/navigator_widget/navigator_helper.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneRegisterScreen extends StatefulWidget {
  const PhoneRegisterScreen({super.key});

  @override
  State<PhoneRegisterScreen> createState() => _PhoneRegisterScreenState();
}

class _PhoneRegisterScreenState extends State<PhoneRegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _validatePhone(String value) {
    if (value.trim().isEmpty) return "Vui lòng nhập số điện thoại".tr();
    if (value.length != 10 || !value.startsWith("0")) {
      return "Số điện thoại phải gồm 10 số, bắt đầu bằng 0".tr();
    }
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
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin".tr())),
      );
      return;
    }

    final phoneError = _validatePhone(_phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(phoneError)));
      return;
    }

    final passError = _validatePassword(_passwordController.text);
    if (passError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(passError)));
      return;
    }

    // Check số điện thoại đã tồn tại chưa
    final existingUser = await _firestore
        .collection('users')
        .where('phone', isEqualTo: _phoneController.text.trim())
        .limit(1)
        .get();

    if (existingUser.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại này đã được đăng ký")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

      await _firestore.collection('users').add({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'fullName': fullName,
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(), // ⚠️ nên mã hoá
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Lưu SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRegistered', true);
      await prefs.setString('name', fullName);
      await prefs.setString('phone', _phoneController.text.trim());

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng ký thành công".tr())),
      );

      /*Navigator.of(context).push(
        CupertinoPageRoute(builder: (_) => const ProfilePhoneScreen()),
      );*/
      context.go('/profile_phone');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
      GestureDetector(
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
                          // Header
                          SizedBox(
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text("Hey there,".tr(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: "Poppins")),
                                    const SizedBox(height: 4),
                                    Text("Create an account".tr(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 22,
                                            fontFamily: "Poppins")),
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

                          // Inputs
                          buildInput(
                            icon: const Icon(Icons.person_outline),
                            hint: "First name".tr(),
                            controller: _firstNameController,
                          ),
                          buildInput(
                            icon: const Icon(Icons.person_outline),
                            hint: "Last name".tr(),
                            controller: _lastNameController,
                          ),
                          buildInput(
                            icon: const Icon(Icons.phone),
                            hint: "Phone number (10 số)".tr(),
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          buildInput(
                            icon: const Icon(Icons.lock_outline),
                            hint: "Password".tr(),
                            controller: _passwordController,
                            obscure: true,
                          ),
                          const SizedBox(height: 15),

                          // Terms & Privacy
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(value: false, onChanged: (value) {}),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        "By continuing you accept our ".tr(),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontFamily: "Poppins"),
                                    children: [
                                      TextSpan(
                                          text: "Privacy Policy".tr(),
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.black)),
                                      const TextSpan(text: " and "),
                                      TextSpan(
                                          text: "Terms of Use".tr(),
                                          style: const TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Register button
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
                                          fontFamily: "Poppins")),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                      thickness: 1, color: Colors.grey)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Text("Or".tr(),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w400)),
                              ),
                              const Expanded(
                                  child: Divider(
                                      thickness: 1, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Social login
                          //const SocialButton(mode: "register",),
                          const SizedBox(height: 25),

                          // Login redirect
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
                                      color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "Login".tr(),
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w600,
                                          color: Colors.pinkAccent),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setBool(
                                              "isRegistered", true);
                                          NavigationHelper.pushCupertino(
                                              context,
                                              const WelcomeScreen(
                                                  fromLogin: true));
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
                ),
              );
            },
          ),
        ),
      );
    
  }
}
