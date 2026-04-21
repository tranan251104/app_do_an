import 'package:app_do_an/navigator/navigator_screen/forgot_password_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/personal_info_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:app_do_an/navigator/navigator_screen/otp_verify_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTabbar extends StatefulWidget {
  const ProfileTabbar({super.key});

  @override
  State<ProfileTabbar> createState() => _ProfileTabbarState();
}

class _ProfileTabbarState extends State<ProfileTabbar> {
  /// 🔹 Lấy thông tin user
  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      // ✅ Login bằng Email / Google / Facebook
      final docRef =
          FirebaseFirestore.instance.collection("users").doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        return doc.data();
      } else {
        final newData = {
          "fullName": user.displayName ?? "",
          "email": user.email ?? "",
          "phone": "",
          "createdAt": FieldValue.serverTimestamp(),
        };
        await docRef.set(newData);
        return newData;
      }
    } else {
      // ✅ Login bằng số điện thoại
      final phone = prefs.getString("user_phone");
      final name = prefs.getString("name") ?? "";

      if (phone != null && phone.isNotEmpty) {
        return {
          "fullName": name,
          "phone": phone,
          "email": "",
        };
      }
    }
    return null;
  }

  /// 🔹 Logout
  Future<void> _logout() async {
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.clear(); // xoá toàn bộ dữ liệu local
    await FirebaseAuth.instance.signOut(); // signout Firebase

    if (!mounted) return;

    // 🔹 Điều hướng về WelcomeScreen
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(fromLogin: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cá nhân"),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Không tìm thấy thông tin người dùng"));
          }

          final data = snapshot.data!;
          final fullName = data['fullName'] ?? "Chưa có tên";
          final email = data['email'] ?? "";
          final phone = data['phone'] ?? "";

          return ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(fullName),
                subtitle: Text(
                  email.isNotEmpty
                      ? email
                      : (phone.isNotEmpty ? phone : "Không có thông tin"),
                ),
              ),
              const Divider(),

              // Hồ sơ cá nhân
              ListTile(
                leading: const Icon(Icons.account_box),
                title: const Text("Hồ sơ cá nhân"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen(),
                    ),
                  );
                },
              ),

              // Đổi mật khẩu
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Đổi mật khẩu"),
                onTap: () async {
                  final currentUser = FirebaseAuth.instance.currentUser;

                  if (currentUser?.email != null &&
                      currentUser!.email!.isNotEmpty) {
                    try {
                      await OtpService.sendOtp(currentUser.email!);

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpVerifyScreen(
                            email: currentUser.email!,
                            mode: PasswordFlowMode.change,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Lỗi khi gửi OTP: $e")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("❌ Chỉ hỗ trợ đổi mật khẩu qua Email")),
                    );
                  }
                },
              ),

              // Ngôn ngữ
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Ngôn ngữ"),
                onTap: () {
                  // TODO: mở màn hình chọn ngôn ngữ
                },
              ),

              // Đăng xuất
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Đăng xuất"),
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}




