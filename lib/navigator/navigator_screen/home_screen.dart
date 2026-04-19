import 'package:app_do_an/navigator/navigator_screen/create_account_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Màn hình 1

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _StateHomeScreen();
}

class _StateHomeScreen extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();  
    _checkLoginAndRedirect();
  }
  
  // Sau 1s se chuyen sang man hinh 
  Future<void> _checkLoginAndRedirect() async {
    await Future.delayed(const Duration(seconds: 1));
    
    //Xu li khi dang nhap se luu 
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if(isLoggedIn){
      Navigator.push(context, CupertinoPageRoute(builder: (_) => TabbarScreen()));
    } 
    else {
      Navigator.push(context, CupertinoPageRoute(builder: (_) => CreateAccountScreen()));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [           
            //Text ở trung tâm
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "An",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.deepPurpleAccent,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700
                  ),
                ),
                Text(
                  "Pay",
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.deepPurpleAccent,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            //Text ở dòng dưới
            Text("Everybody can train", 
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400
              ),
            ),            
          ],
        ),
      ),
    );
  }
}

