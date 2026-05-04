import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class QrMainScreen extends StatefulWidget {
  const QrMainScreen({super.key});

  @override
  State<QrMainScreen> createState() => _QrMainScreenState();
}

class _QrMainScreenState extends State<QrMainScreen> {
  int _currentIndex = 0;
  late MobileScannerController _controller;
  String _username = "Người dùng";
  String _uid = "";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _username = prefs.getString("name") ?? user?.displayName ?? "Người dùng Demo";
      _uid = user?.uid ?? "demo_user_123";
    });
  }

  // 🔹 Xử lý khi quét mã
  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing || _currentIndex == 0) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    final String code = barcode.rawValue!;
    setState(() => _isProcessing = true);

    // 1. Kiểm tra nếu là Link thanh toán Web của chính bạn
    if (code.contains("app-do-an-ae40f.web.app")) {
      final uri = Uri.parse(code);
      final targetUid = uri.queryParameters['uid'] ?? "";
      final targetName = Uri.decodeComponent(uri.queryParameters['name'] ?? "Người nhận");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransferMoneyFormScreen(
            account: PaymentAccount(
              accountNumber: targetUid,
              name: targetName,
              provider: "ANPAY Web",
              isService: false,
            ),
          ),
        ),
      ).then((_) => setState(() => _isProcessing = false));
    }
    // 2. Nếu là mã VietQR truyền thống
    else if (code.startsWith("000201")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransferMoneyFormScreen(
            account: PaymentAccount.fromBank(
              bankName: "ANPAY QR",
              accountNumber: "9704 0000 0000 0000",
              ownerName: "Người nhận Demo",
            ),
          ),
        ),
      ).then((_) => setState(() => _isProcessing = false));
    }
    // 3. Nếu là link web bình thường thì mở trình duyệt
    else if (code.startsWith("http")) {
      _launchURL(code);
    }
    else {
      _showResultDialog(code);
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    setState(() => _isProcessing = false);
  }

  void _showResultDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kết quả quét"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
            },
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Đường link Web thanh toán thực tế của bạn
    final String webPaymentLink = "https://app-do-an-ae40f.web.app/?uid=$_uid&name=${Uri.encodeComponent(_username)}";

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "Mã QR của tôi" : "Quét QR"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // ---------------- TAB 1: MÃ QR CHỨA LINK WEB ----------------
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      const Text("Quét để thanh toán cho tôi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      // Tạo QR từ link Web
                      Image.network(
                        "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(webPaymentLink)}",
                        width: 220, height: 220,
                      ),
                      const SizedBox(height: 16),
                      Text(_username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Quét bằng Camera hoặc App ANPAY", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Dùng điện thoại quét mã này sẽ mở trang web để chuyển tiền trực tiếp cho bạn.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- TAB 2: QUÉT QR ----------------
          Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _handleBarcode,
              ),
              Center(
                child: Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Mã QR của tôi"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Quét QR"),
        ],
      ),
    );
  }
}
