import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/bankAccount1.dart';

class QRScanScreen extends StatefulWidget {
  final bool isTab; 
  const QRScanScreen({super.key, this.isTab = true});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Khởi động lại camera khi quay lại app để tránh màn hình trắng
    if (state == AppLifecycleState.resumed) {
      _resumeScanner();
    }
  }

  void _handleScan(String code) async {
    if (_isScanned) return;
    setState(() => _isScanned = true);
    
    await _controller.stop();
    print("🔍 Quét được mã: $code");

    // 1. Nếu là mã VietQR (EMVCo chuẩn ngân hàng)
    if (code.startsWith("000201")) {
      _processVietQR(code);
    } 
    // 2. Nếu là Link thanh toán trực tiếp (PayOS/Web)
    else if (code.startsWith("http")) {
      final uri = Uri.parse(code);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      _resumeScanner();
    } 
    // 3. Các loại mã khác thì hiện thông báo
    else {
      _showResultDialog(code);
    }
  }

  void _processVietQR(String qrCode) {
    // Phân tích mã VietQR cơ bản để lấy thông tin ngân hàng và STK
    // Trong thực tế cần parser chuẩn, ở đây ta demo việc chuyển tới màn hình chuyển tiền thật
    
    String bankName = "Ngân hàng (VietQR)";
    String accountNumber = "Đang lấy...";
    
    // Tìm mã ngân hàng (BIN) trong chuỗi VietQR (thường nằm sau tag 38)
    if (qrCode.contains("970422")) bankName = "MB Bank";
    else if (qrCode.contains("970436")) bankName = "Vietcombank";
    else if (qrCode.contains("970407")) bankName = "Techcombank";

    // Điều hướng tới màn hình nhập số tiền để "Chuyển tiền thật"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(
          account1: BankAccount1(
            bankName: bankName,
            accountNumber: "Số tài khoản từ QR",
            ownerName: "Người nhận mã QR",
          ),
        ),
      ),
    ).then((_) => _resumeScanner());
  }

  void _resumeScanner() {
    if (mounted) {
      setState(() => _isScanned = false);
      _controller.start();
    }
  }

  void _showResultDialog(String text) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thông tin QR"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanner();
            },
            child: const Text("Quét tiếp"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quét mã QR"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !widget.isTab,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Khung quét trang trí
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                   Align(
                     alignment: Alignment.center,
                     child: Container(height: 1, width: 220, color: Colors.red),
                   )
                ],
              ),
            ),
          ),
          if (_isScanned)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
