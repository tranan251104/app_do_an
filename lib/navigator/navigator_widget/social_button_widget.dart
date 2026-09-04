import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String mode;
  final VoidCallback? onToggleMode;
  final bool isPhonePage;

  const SocialButton({
    super.key,
    required this.mode,
    this.onToggleMode,
    this.isPhonePage = false,
  });

  void _googlePending(BuildContext context) {
    AppLogger.action('GOOGLE sign-in button pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Google Sign-In đang tạm khóa cho tới khi backend hỗ trợ đổi Google ID token sang JWT AnPay.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialBtn(
          onTap: () => _googlePending(context),
          child: Image.asset('assets/images/google.png'),
        ),
        const SizedBox(width: 40),
        _buildSocialBtn(
          onTap: () {
            AppLogger.action('LOGIN method toggle button pressed', {'isPhonePage': isPhonePage});
            (onToggleMode ?? () {})();
          },
          child: Icon(
            isPhonePage ? Icons.email_outlined : Icons.phone_android,
            color: isPhonePage ? Colors.blueAccent : Colors.green,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBtn({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return SizedBox(
      height: 50,
      width: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(10),
          backgroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}
