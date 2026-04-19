import 'package:app_do_an/navigator/navigator_tabbar/home_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/profile_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/schedule_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/topup_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_do_an/navigator/qr/qr_scan_screen.dart'; // 👈 dùng QrMainScreen

class TabbarScreen extends StatefulWidget {
  const TabbarScreen({super.key});

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTabbar(),
    const TopUpTabbar(),
    const QRScanScreen(),   // 👈 hiển thị luôn trong tab QR
    const ScheduleTabbar(),
    const ProfileTabbar(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Ưu đãi"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "QR"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử GD"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
          ],
        ),
      ),
    );
  }
}
