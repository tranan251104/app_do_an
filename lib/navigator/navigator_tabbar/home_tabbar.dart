/*import 'package:app_do_an/navigator/navigator_screen/bill_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/lottery_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/qr_main_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/travel_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/navigator_tabbar/topup_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/schedule_tabbar.dart';
import 'package:app_do_an/navigator/secondary_screen/recharge_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transfermoney_screen.dart';
import 'package:app_do_an/navigator/navigator_tabbar/telecom_screen.dart'; // import TelecomScreen

class HomeTabbar extends StatefulWidget {
  const HomeTabbar({super.key});

  @override
  State<HomeTabbar> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends State<HomeTabbar> {
  bool _isHidden = true;
  int _walletBalance = 0;

  final GlobalKey<ScheduleTabbarState> scheduleKey =
      GlobalKey<ScheduleTabbarState>();

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  /// 🔹 Load số dư từ SharedPreferences
  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletBalance = prefs.getInt("wallet_balance") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menu Phổ biến
    final List<Map<String, dynamic>> popularItems = [
      {"icon": Icons.phone_android, "label": "Viễn thông"},
      {"icon": Icons.local_activity, "label": "Xổ số, giải trí"},
      {"icon": Icons.receipt_long, "label": "Hóa đơn"},
      {"icon": Icons.flight_takeoff, "label": "Du lịch, đi lại"},
      {"icon": Icons.attach_money, "label": "Vay tiền mặt"},
      {"icon": Icons.health_and_safety, "label": "Mua bảo hiểm"},
      {"icon": Icons.savings, "label": "Gửi tiết kiệm"},
      {"icon": Icons.apps, "label": "Xem tất cả"},
    ];

    // Menu Ưu đãi đối tác
    final List<Map<String, dynamic>> partnerItems = [
      {"icon": Icons.videogame_asset, "label": "Garena"},
      {"icon": Icons.movie, "label": "CGV"},
      {"icon": Icons.theaters, "label": "Galaxy"},
      {"icon": Icons.local_shipping, "label": "SPX"},
      {"icon": Icons.tv, "label": "FPT Play"},
      {"icon": Icons.confirmation_num, "label": "Ticketbox"},
      {"icon": Icons.video_library, "label": "VieON"},
      {"icon": Icons.apps, "label": "Xem thêm"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text("AnPay", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Tổng số dư
            Container(
              width: double.infinity,
              color: Colors.purple,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tổng số dư",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _isHidden ? "đ ***" : "đ $_walletBalance",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 🔹 Hàng button nhanh
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickButton(context, Icons.add_card, "Nạp tiền", () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RechargeScreen()),
                    );

                    if (result == true) {
                      _loadBalance();
                      scheduleKey.currentState?.loadTransactions();
                    }
                  }),
                  _quickButton(context, Icons.send, "Chuyển tiền", () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TransferMoneyScreen()),
                    );
                    if (result == true) {
                      _loadBalance();
                    }
                  }),
                  _quickButton(context, Icons.qr_code_scanner,
                      "QR của tôi", () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QrMainScreen()),
                    );
                  }),
                  _quickButton(context, Icons.local_activity, "Ưu đãi",
                      () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TopUpTabbar(showBackButton: true)),
                    );
                  }),
                ],
              ),
            ),

            const Divider(),

            // 🔹 TabBar + TabBarView
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.purple,
                    unselectedLabelColor: Colors.black,
                    indicatorColor: Colors.purple,
                    tabs: [
                      Tab(text: "Phổ biến"),
                      Tab(text: "Ưu đãi Đối tác"),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildGrid(popularItems),
                        _buildGrid(partnerItems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(BuildContext context, IconData icon, String label,
      [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.shade50,
            radius: 28,
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// ✅ cập nhật để có onTap navigate
  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            switch (item["label"]) {
              case "Viễn thông":
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelecomScreen(walletBalance: _walletBalance)),
                );
              case "Xổ số, giải trí":
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => LotteryScreen(walletBalance: _walletBalance,))
                );
              case "Hóa đơn":
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => BillScreen())
                );
              case "Du lịch, đi lại":
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => TravelScreen(walletBalance: _walletBalance,))
                );
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("🚧 ${item["label"]} đang phát triển")),
                );
            }
          },
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade50,
                radius: 26,
                child: Icon(item["icon"], color: Colors.purple),
              ),
              const SizedBox(height: 6),
              Text(
                item["label"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),
        );
      },
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app_do_an/navigator/navigator_screen/bill_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/lottery_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/qr_main_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/travel_screen.dart';
import 'package:app_do_an/navigator/navigator_tabbar/topup_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/telecom_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/recharge_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transfermoney_screen.dart';
import 'schedule_tabbar.dart';

class HomeTabbar extends StatefulWidget {
  const HomeTabbar({super.key});

  @override
  State<HomeTabbar> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends State<HomeTabbar> {
  bool _isHidden = true;
  int _walletBalance = 0;

  final GlobalKey<ScheduleTabbarState> scheduleKey =
      GlobalKey<ScheduleTabbarState>();

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _listenBalance(); // 🔹 realtime listener
  }

  /// Lấy số dư từ Firestore và cache lại local
  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!['balance'] != null) {
        setState(() {
          _walletBalance = doc['balance'] as int;
        });
        await prefs.setInt("wallet_balance", _walletBalance);
        return;
      }
    }
    // fallback lấy cache local
    setState(() {
      _walletBalance = prefs.getInt("wallet_balance") ?? 0;
    });
  }

  /// Nghe realtime thay đổi số dư
  void _listenBalance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) async {
        if (doc.exists && doc.data()!['balance'] != null) {
          final newBalance = doc['balance'] as int;
          setState(() => _walletBalance = newBalance);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt("wallet_balance", newBalance);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> popularItems = [
      {"icon": Icons.phone_android, "label": "Viễn thông"},
      {"icon": Icons.local_activity, "label": "Xổ số, giải trí"},
      {"icon": Icons.receipt_long, "label": "Hóa đơn"},
      {"icon": Icons.flight_takeoff, "label": "Du lịch, đi lại"},
      {"icon": Icons.attach_money, "label": "Vay tiền mặt"},
      {"icon": Icons.health_and_safety, "label": "Mua bảo hiểm"},
      {"icon": Icons.savings, "label": "Gửi tiết kiệm"},
      {"icon": Icons.apps, "label": "Xem tất cả"},
    ];

    final List<Map<String, dynamic>> partnerItems = [
      {"icon": Icons.videogame_asset, "label": "Garena"},
      {"icon": Icons.movie, "label": "CGV"},
      {"icon": Icons.theaters, "label": "Galaxy"},
      {"icon": Icons.local_shipping, "label": "SPX"},
      {"icon": Icons.tv, "label": "FPT Play"},
      {"icon": Icons.confirmation_num, "label": "Ticketbox"},
      {"icon": Icons.video_library, "label": "VieON"},
      {"icon": Icons.apps, "label": "Xem thêm"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text("AnPay", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Tổng số dư
            Container(
              width: double.infinity,
              color: Colors.purple,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tổng số dư",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _isHidden ? "đ ***" : "đ $_walletBalance",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() => _isHidden = !_isHidden);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 🔹 Button nhanh
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickButton(context, Icons.add_card, "Nạp tiền", () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RechargeScreen()),
                    );
                    if (result == true) _loadBalance();
                  }),
                  _quickButton(context, Icons.send, "Chuyển tiền", () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TransferMoneyScreen()),
                    );
                    if (result == true) _loadBalance();
                  }),
                  _quickButton(context, Icons.qr_code_scanner, "QR của tôi",
                      () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrMainScreen()),
                    );
                  }),
                  _quickButton(context, Icons.local_activity, "Ưu đãi",
                      () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const TopUpTabbar(showBackButton: true)),
                    );
                  }),
                ],
              ),
            ),

            const Divider(),

            // 🔹 TabBar + Grid menu
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.purple,
                    unselectedLabelColor: Colors.black,
                    indicatorColor: Colors.purple,
                    tabs: [
                      Tab(text: "Phổ biến"),
                      Tab(text: "Ưu đãi Đối tác"),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildGrid(popularItems),
                        _buildGrid(partnerItems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(
      BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.shade50,
            radius: 28,
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            switch (item["label"]) {
              case "Viễn thông":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TelecomScreen(walletBalance: _walletBalance)),
                );
                break;
              case "Xổ số, giải trí":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LotteryScreen(walletBalance: _walletBalance)),
                );
                break;
              case "Hóa đơn":
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BillScreen()),
                );
                break;
              case "Du lịch, đi lại":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TravelScreen(walletBalance: _walletBalance)),
                );
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("🚧 ${item["label"]} đang phát triển")),
                );
            }
          },
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade50,
                radius: 26,
                child: Icon(item["icon"], color: Colors.purple),
              ),
              const SizedBox(height: 6),
              Text(
                item["label"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),
        );
      },
    );
  }
}

