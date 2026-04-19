import 'package:app_do_an/navigator/navigator_screen/main_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/input_widget.dart';
import 'package:app_do_an/navigator/navigator_widget/navigator_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/navigator_screen/forgot_password_phone_screen.dart';


class WelcomePhoneScreen extends StatefulWidget {
  const WelcomePhoneScreen({super.key});

  @override
  State<WelcomePhoneScreen> createState() => _WelcomePhoneScreenState();
}

class _WelcomePhoneScreenState extends State<WelcomePhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _handleLogin() async {
  if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vui lòng nhập số điện thoại và mật khẩu".tr())),
    );
    return;
  }

  final phone = _phoneController.text.trim();
  if (phone.length != 10 || !phone.startsWith("0")) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Số điện thoại phải gồm 10 số, bắt đầu bằng 0")),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception("Không tìm thấy tài khoản này.");
    }

    final user = query.docs.first.data();
    final savedPass = user['password'] ?? "";

    if (savedPass != _passwordController.text.trim()) {
      throw Exception("Sai mật khẩu.");
    }

    // ✅ Lưu SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("login_method", "phone");
    await prefs.setString("user_phone", phone);
    await prefs.setString("name", user['fullName'] ?? "");
    await prefs.remove("user_email"); // xoá email nếu có

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // đóng loading

    NavigationHelper.pushCupertino(
      context,
      const MainScreen(fromLogin: true),
    );
  } catch (e) {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Hey there,".tr(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w400)),
                        Text("Welcome back".tr(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins")),
                        const SizedBox(height: 20),

                        // 🔹 Phone Input
                        buildInput(
                          icon: const Icon(Icons.phone),
                          hint: "Phone number (10 số)".tr(),
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),

                        // 🔹 Password Input
                        buildInput(
                          icon: const Icon(Icons.lock),
                          hint: "Password".tr(),
                          controller: _passwordController,
                          obscure: true,
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPhoneScreen(),
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

                        // 🔹 Login button
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
                                child: Divider(thickness: 1, color: Colors.grey)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(" Or ".tr(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Inter")),
                            ),
                            const Expanded(
                                child: Divider(thickness: 1, color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 3),
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


