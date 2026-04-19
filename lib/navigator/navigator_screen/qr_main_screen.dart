import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrMainScreen extends StatefulWidget {
  const QrMainScreen({super.key});

  @override
  State<QrMainScreen> createState() => _QrMainScreenState();
}

class _QrMainScreenState extends State<QrMainScreen> {
  int _currentIndex = 0;
  String? qrResult;
  late MobileScannerController _controller;

  String _username = "Người dùng"; // 👈 tên động từ Profile

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("name") ?? "Người dùng";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scanBoxSize = 250;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "Mã QR của tôi" : "Quét QR"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // ---------------- TAB 1: MÃ QR CỦA TÔI ----------------
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // QR + tên người dùng
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo thương hiệu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Ngân Hàng Số ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "ANPAY",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Ảnh QR (fix cứng hoặc generate)
                      const Image(
                        image: AssetImage("assets/images/myQR.jpeg"),
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),

                      // 👉 Tên chủ tài khoản (động từ SharedPreferences)
                      Text(
                        _username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Thông tin cài đặt
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CÀI ĐẶT",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Tài khoản",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Text("ANPAY",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Số tiền nhận",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Text("Không có",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Số tài khoản
                Column(
                  children: [
                    const Text(
                      "Số tài khoản ANPAY",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "9704 2292 0361 0941 950",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã sao chép")),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Gợi ý dưới cùng
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.store, color: Colors.black54),
                  label: const Text(
                    "Đăng ký trở thành Cửa hàng",
                    style: TextStyle(color: Colors.black54),
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
                fit: BoxFit.cover,
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    if (barcode.rawValue != null) {
                      setState(() => qrResult = barcode.rawValue);
                    }
                  }
                },
              ),
              Center(
                child: Container(
                  width: scanBoxSize,
                  height: scanBoxSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (qrResult != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      "Kết quả: $qrResult",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      // ---------------- BOTTOM SWITCH ----------------
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentIndex = 0),
                icon: const Icon(Icons.qr_code),
                label: const Text("Mã QR của tôi"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => setState(() => _currentIndex = 1),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("Quét QR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




