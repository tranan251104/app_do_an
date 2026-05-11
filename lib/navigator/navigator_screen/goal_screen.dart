// Man hinh quang cao phia ngoai truoc khi vao app, sau nay se khong xuat hien nua 

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Màn hình 4

class GoalScreen extends StatefulWidget {
  @override
  State<GoalScreen> createState() => _StateGoalScreen();
}

class _StateGoalScreen extends State<GoalScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
     "image": "assets/images/icon3.png",
     "title": "Easy Account Setup".tr(),
     "description": "Open your bank account in minutes,".tr(),
     "description2": "no paperwork required,".tr(),
     "description3": "quick and secure verification.".tr()
    },
    {
      "image": "assets/images/icon2.png",
      "title": "Fast & Secure Transfers".tr(),
      "description": "Send and receive money instantly,".tr(),
      "description2": "with advanced protection to keep".tr(),
      "description3": "your transactions safe.".tr()
    },
    {
      "image": "assets/images/icon3.png",
      "title": "Smart & Convenient Payments".tr(),
      "description": "Pay bills, top up services,".tr(),
      "description2": "and manage your expenses".tr(),
      "description3": "all in one app.".tr(),
    },
  ];

  @override
  Widget build(BuildContext context) {        
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              //Phan text tren cung
              Text(
                "What is your goal ?".tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: "Poppins"),
              ),
              const SizedBox(height: 8),
              Text(
                "It will help us to choose a best".tr(),
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: "Poppins"),
              ),
              const SizedBox(height: 3),
              Text(
                "program for you".tr(),
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 12, fontFamily: "Poppins"),
              ),
              const SizedBox(height: 16),

              // Phan anh va o o trung tam
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        // Phan hop duoc boc ngoai anh va chu
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade100, Colors.blue.shade200],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Phan anh
                            Expanded(
                              child: Image.asset(
                                page["image"]!,
                                fit: BoxFit.contain,
                              ),
                            ),

                            //Tieu de
                            const SizedBox(height: 16),
                            Text(
                              page["title"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins"
                              ),
                            ),

                            // Duong ke ngan cach
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 100),
                              child: Divider(thickness: 1, color: Colors.white),
                            ),

                            //Text dong 1
                            const SizedBox(height: 5),
                            Text(
                              page["description"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400, fontFamily: "Poppins"),
                            ),

                            // Text dong 2
                            const SizedBox(height: 3),
                            Text(
                              page["description2"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400, fontFamily: "Poppins"),
                            ),

                            // Text dong 3
                            const SizedBox(height: 3),
                            Text(
                              page["description3"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400, fontFamily: "Poppins"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Button Confirm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {        
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isRegistered', true);

                      // 🔹 Chuyển sang màn hình Main (Màn hình Welcome to AnPay) sau khi hoàn tất
                      context.go('/main');
                    },
                    child: Text(
                      "Confirm".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: "Poppins"
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    
  }
}
