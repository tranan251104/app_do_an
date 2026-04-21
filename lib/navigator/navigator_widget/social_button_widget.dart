import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialButton extends StatelessWidget {
  final String mode; // "register" hoặc "login"
  final VoidCallback? onToggleMode; // 🔹 Callback để chuyển đổi Email/Phone
  final bool isPhonePage; // 🔹 Cho biết icon nào cần hiện (Email hay Phone)

  const SocialButton({
    super.key, 
    required this.mode, 
    this.onToggleMode, 
    this.isPhonePage = false
  });

  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Google thành công!")));
    } catch (e) {
      debugPrint("Google login error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialBtn(
          onTap: () => _loginWithGoogle(context),
          child: Image.asset("assets/images/google.png"),
        ),
        const SizedBox(width: 40),
        // 🔹 Đổi icon dựa trên trang hiện tại
        _buildSocialBtn(
          onTap: onToggleMode ?? () {}, 
          child: Icon(
            isPhonePage ? Icons.email_outlined : Icons.phone_android, 
            color: isPhonePage ? Colors.blueAccent : Colors.green, 
            size: 26
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBtn({required VoidCallback onTap, required Widget child}) {
    return SizedBox(
      height: 50,
      width: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(10),
          backgroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      ),
    );
  }
}
