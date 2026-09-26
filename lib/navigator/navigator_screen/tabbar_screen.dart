import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/navigator_tabbar/home_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/profile_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/schedule_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/topup_tabbar.dart';
import 'package:app_do_an/navigator/qr/qr_scan_screen.dart';
import 'package:app_do_an/navigator/service/notification_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TabbarScreen extends StatefulWidget {
  final int initialIndex;
  final String? homeAction;
  final String? initialTransactionId;
  final String? navigationToken;

  const TabbarScreen({
    super.key,
    this.initialIndex = 0,
    this.homeAction,
    this.initialTransactionId,
    this.navigationToken,
  });

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  late int _selectedIndex;
  final GlobalKey<ScheduleTabbarState> _historyKey =
      GlobalKey<ScheduleTabbarState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4).toInt();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationNavigationService.openPendingIfAuthenticated();
    });
  }

  @override
  void didUpdateWidget(covariant TabbarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = widget.initialIndex.clamp(0, 4).toInt();
    if (nextIndex != _selectedIndex) {
      setState(() => _selectedIndex = nextIndex);
    }
  }

  void _onItemTapped(int index) {
    AppLogger.action('MAIN TAB pressed', {'index': index});
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _historyKey.currentState?.refreshFromOutside();
      });
    }
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
          children: [
            HomeTabbar(
              initialAction: widget.homeAction,
              navigationToken: widget.navigationToken,
            ),
            const TopUpTabbar(),
            QRScanScreen(isTab: true, isActive: _selectedIndex == 2),
            ScheduleTabbar(
              key: _historyKey,
              initialTransactionId: widget.initialTransactionId,
              navigationToken: widget.navigationToken,
            ),
            const ProfileTabbar(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num),
              label: "Ưu đãi",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "QR"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử GD"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
          ],
        ),
      ),
    );
  }
}
