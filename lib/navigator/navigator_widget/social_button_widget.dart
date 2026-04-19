import 'package:app_do_an/navigator/navigator_screen/create_account_phone_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_phone_screen.dart'; // 👈 màn login bằng SĐT
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialButton extends StatelessWidget {
  final String mode; // "register" hoặc "login"

  const SocialButton({super.key, required this.mode});

  // 🔹 Google Login
  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Người dùng hủy login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Google thành công!")),
      );
    } catch (e) {
      debugPrint("Google login error: $e");
    }
  }

  // 🔹 Phone Login
  void _loginWithPhone(BuildContext context) {
    if (mode == "register") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PhoneRegisterScreen()),
      );
    } else if (mode == "login") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePhoneScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        SizedBox(
          height: 50,
          width: 50,
          child: ElevatedButton(
            onPressed: () => _loginWithGoogle(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Image.asset("assets/images/google.png"),
          ),
        ),
        const SizedBox(width: 60),

        // Phone Button
        SizedBox(
          height: 50,
          width: 50,
          child: ElevatedButton(
            onPressed: () => _loginWithPhone(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Icon(
              Icons.phone_android,
              color: Colors.green,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

