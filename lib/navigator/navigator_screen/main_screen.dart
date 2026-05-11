import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final bool fromLogin;
  const MainScreen({super.key, required this.fromLogin});

  @override
  State<MainScreen> createState() => _StateMainScreen();
}

class _StateMainScreen extends State<MainScreen> {
  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: true, 
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(); 
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Image.asset("assets/images/AnPay.png"),
                ),

                const SizedBox(height: 16),
                Text(
                  "Welcome to AnPay".tr(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                ),
                const SizedBox(height: 8),
                Text("You are all set now, let’s reach your".tr(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: "Poppins"),),
                Text("money together with us".tr(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontFamily: "Poppins"),),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                      
                      // 🔹 Chuyển vào Tabbar bằng GoRouter
                      if (mounted) context.go('/tabbar');
                    },
                    child: Text("Go to home".tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poppins"))
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
