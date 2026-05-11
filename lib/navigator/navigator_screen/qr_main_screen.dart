import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/qr/qr_scan_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Thêm Firestore để lấy tên profile
import 'package:flutter/services.dart';

class QrMainScreen extends StatefulWidget {
  final bool isTab;
  final bool isActive;

  const QrMainScreen({
    super.key,
    this.isTab = false,
    this.isActive = true,
  });

  @override
  QrMainScreenState createState() => QrMainScreenState();
}

class QrMainScreenState extends State<QrMainScreen> {
  int _currentIndex = 0;
  String _username = "Đang tải...";
  String _rawUid = ""; // UID gốc để tạo link
  String _displayUid = ""; // UID định dạng để hiển thị

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Nếu không có user đăng nhập, reset về N/A ngay
    if (user == null) {
      if (mounted) {
        setState(() {
          _username = "N/A";
          _rawUid = "";
          _displayUid = "";
        });
      }
      return;
    }

    final String currentUid = user.uid;
    String name = "";

    try {
      // 🔹 ƯU TIÊN 1: Lấy trực tiếp từ Firestore theo UID hiện tại (Để tránh dùng nhầm cache của acc cũ)
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUid).get();
      if (doc.exists) {
        name = doc.data()?['fullName'] ?? "";
      }
      
      // 🔹 ƯU TIÊN 2: Nếu Firestore chưa có tên, thử lấy từ Firebase Auth Display Name
      if (name.isEmpty) {
        name = user.displayName ?? "";
      }

      // 🔹 Cập nhật lại SharedPreferences cho đúng với tài khoản hiện tại
      final prefs = await SharedPreferences.getInstance();
      if (name.isNotEmpty) {
        await prefs.setString("name", name);
      } else {
        // Nếu acc mới hoàn toàn không có tên, xóa cache cũ để tránh hiển thị sai
        await prefs.remove("name");
        name = "N/A";
      }
    } catch (e) {
      debugPrint("Lỗi tải thông tin người dùng: $e");
      name = "N/A";
    }

    if (!mounted) return;

    setState(() {
      _username = name.toUpperCase();
      _rawUid = currentUid;
      
      // Định dạng số tài khoản hiển thị cho đẹp
      if (_rawUid.length >= 12) {
        _displayUid = "9704 ${_rawUid.substring(0, 4)} ${_rawUid.substring(4, 8)} ${_rawUid.substring(8, 12)}";
      } else {
        _displayUid = "9704 2292 0361 0941 950"; 
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã sao chép số tài khoản"),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 QUAN TRỌNG: Link QR sử dụng _rawUid (không dấu cách) để Web index.html tìm đúng document trong Firestore
    final String webPaymentLink = "https://app-do-an-ae40f.web.app/?uid=$_rawUid&name=${Uri.encodeComponent(_username)}";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "QR nhận tiền" : "Quét mã QR"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.isTab,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.black87),
              onPressed: () {},
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 1. Mục QR của tôi
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.purple, size: 30),
                            const SizedBox(width: 8),
                            const Text("ANPAY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple)),
                            const SizedBox(width: 16),
                            Container(width: 1, height: 24, color: Colors.grey[300]),
                            const SizedBox(width: 16),
                            const Text("Viet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                            const Text("QR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[100]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(webPaymentLink)}",
                              width: 220, height: 220,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.purple, size: 24),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(_username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 0.5),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("CÀI ĐẶT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                Icon(Icons.keyboard_arrow_up, color: Colors.grey[600], size: 20),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              "Tài khoản", 
                              "Ví ANPAY", 
                              trailing: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 12),
                              ),
                              isBoldValue: true,
                            ),
                            const SizedBox(height: 14),
                            _buildInfoRow("Số tiền nhận", "Không có", hasArrow: true),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.5),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Text("Số tài khoản Ví ANPAY", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_displayUid, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _copyToClipboard(_displayUid),
                                  child: Icon(Icons.copy_rounded, size: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 20, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text("Đăng ký trở thành Cửa hàng", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // 2. Mục Quét QR
          QRScanScreen(
            isTab: true,
            isActive: widget.isActive && _currentIndex == 1,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded), label: "Nhận tiền"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: "Quét mã"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool hasArrow = false, bool isBoldValue = false, Widget? trailing}) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const Spacer(),
        if (trailing != null) ...[trailing, const SizedBox(width: 8)],
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (hasArrow) const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      ],
    );
  }
}
