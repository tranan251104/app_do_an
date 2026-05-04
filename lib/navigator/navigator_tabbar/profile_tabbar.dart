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
  Future<Map<String, dynamic>?> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) return doc.data();
      
      final newData = {
        "fullName": user.displayName ?? "",
        "email": user.email ?? "",
        "phone": "",
        "createdAt": FieldValue.serverTimestamp(),
      };
      await docRef.set(newData);
      return newData;
    } else {
      final phone = prefs.getString("user_phone");
      final name = prefs.getString("name") ?? "";
      if (phone != null && phone.isNotEmpty) {
        return {"fullName": name, "phone": phone, "email": ""};
      }
    }
    return null;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen(fromLogin: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cá nhân"), automaticallyImplyLeading: false),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text("Không tìm thấy thông tin"));

          final data = snapshot.data!;
          return ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['fullName'] ?? "Chưa có tên"),
                subtitle: Text(data['email']?.isNotEmpty == true ? data['email'] : (data['phone'] ?? "Không có thông tin")),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_box),
                title: const Text("Hồ sơ cá nhân"),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Đổi mật khẩu"),
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user?.email != null) {
                    try {
                      await OtpService.sendOtp(user!.email!);
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpVerifyScreen(
                            identifier: user.email!,
                            isPhoneMode: false,
                            mode: PasswordFlowMode.change,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
                    }
                  }
                },
              ),
              ListTile(leading: const Icon(Icons.logout), title: const Text("Đăng xuất"), onTap: _logout),
            ],
          );
        },
      ),
    );
  }
}
