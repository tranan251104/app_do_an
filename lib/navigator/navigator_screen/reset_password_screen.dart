import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passController = TextEditingController();
  bool _loading = false;

  String? _validatePassword(String value) {
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    return null;
  }

  Future<void> _resetPassword() async {
    AppLogger.action('RESET PASSWORD button pressed');
    final newPass = _passController.text;
    final error = _validatePassword(newPass);
    if (error != null) {
      _show(error);
      return;
    }
    setState(() => _loading = true);
    try {
      await AppServices.auth.forgotPasswordReset(widget.resetToken, newPass);
      if (!mounted) return;
      _show('Đặt lại mật khẩu thành công');
      Navigator.popUntil(context, (route) => route.isFirst);
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lại mật khẩu')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _resetPassword,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Đặt lại mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
