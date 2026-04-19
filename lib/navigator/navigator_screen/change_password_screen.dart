import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({super.key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _loading = false;

  Future<void> _changePassword() async {
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: widget.email,
        password: _oldPassController.text.trim(),
      );

      // Re-authenticate
      await user!.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newPassController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đổi mật khẩu thành công")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _oldPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu hiện tại",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu mới",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _changePassword,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Xác nhận đổi mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
