import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          Navigator.of(context).pop(); // Quay về WelcomeScreen
        }
      },
      
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Phan anh tren cung
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: double.infinity,
                  child: Image.asset("assets/images/AnPay.png"),
                ),

                // Phan Text o duoi
                SizedBox(height: 16),
                Text(
                  "Welcome to AnPay".tr(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: "Poppins"),
                ),
                Text("You are all set now, let’s reach your".tr(), style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w400),),
                Text("money together with us".tr(), style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.w400),),
                Spacer(),

                // Button Go to home
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                      Navigator.push(context, CupertinoPageRoute(builder: (_) => TabbarScreen()));
                    },
                    child: Text("Go to home".tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: "Poppins"))
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}




