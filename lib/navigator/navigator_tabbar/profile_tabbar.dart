import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:app_do_an/navigator/navigator_screen/change_password_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/personal_info_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTabbar extends StatefulWidget {
  const ProfileTabbar({super.key});

  @override
  State<ProfileTabbar> createState() => _ProfileTabbarState();
}

class _ProfileTabbarState extends State<ProfileTabbar> {
  Future<Map<String, dynamic>> _fetchUserData() => AppServices.user.me();

  Future<void> _logout() async {
    AppLogger.action('LOGOUT pressed');
    await NotificationService.unregisterCurrentDevice();
    await AppServices.auth.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen(fromLogin: true)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân'), automaticallyImplyLeading: false),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is ApiException ? error.message : error.toString();
            return Center(child: Text(message));
          }

          final data = snapshot.data ?? const <String, dynamic>{};
          final fullName = data['fullName']?.toString() ?? '';
          final email = data['email']?.toString() ?? '';
          final phone = data['phone']?.toString() ?? '';

          return ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(fullName.isEmpty ? 'Chưa có tên' : fullName),
                subtitle: Text(email.isNotEmpty ? email : (phone.isNotEmpty ? phone : 'Không có thông tin')),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_box),
                title: const Text('Hồ sơ cá nhân'),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen()));
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Đổi mật khẩu'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangePasswordScreen(email: email)),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}
