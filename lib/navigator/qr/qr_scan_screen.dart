import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/service/scanner_service.dart';

class QRScanScreen extends StatefulWidget {
  final bool isTab;
  final bool isActive;

  const QRScanScreen({
    super.key,
    this.isTab = true,
    this.isActive = true,
  });

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with WidgetsBindingObserver {
  MobileScannerController get _controller => ScannerService.instance;
  
  // 🔹 STATIC LOCK: Ngăn chặn tuyệt đối việc push 2 lần
  static bool _isGlobalProcessing = false;
  
  bool _isScanned = false;
  bool _isCooldown = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _startScanner();
    }
  }

  @override
  void didUpdateWidget(QRScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startScanner();
      } else {
        _stopScanner();
      }
    }
  }

  Future<void> _startScanner() async {
    if (!widget.isActive) return;
    await ScannerService.start();
  }

  Future<void> _stopScanner() async {
    await ScannerService.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Chỉ stop camera khi widget bị hủy hoàn toàn khỏi widget tree
    _stopScanner();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.resumed) {
      _startScanner();
    } else if (state == AppLifecycleState.paused) {
      _stopScanner();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      // 🔹 SỬA LỖI MÀN HÌNH ĐEN: 
      // Không dừng camera khi Navigator.push (màn hình khác đè lên).
      // Chỉ dừng camera khi người dùng chuyển sang Tab khác (isActive = false).
      if (widget.isActive) {
        _startScanner();
      } else {
        _stopScanner();
      }
    }
  }

  void _handleScan(String code) async {
    // Kiểm tra cờ chặn
    if (_isGlobalProcessing || _isScanned || _isCooldown || !mounted) return;
    
    _isGlobalProcessing = true; 
    setState(() => _isScanned = true);
    
    // 🔹 CHIẾN THUẬT: Giữ camera chạy ngầm để khi quay lại không bị đen và treo driver.

    if (code.contains("app-do-an-ae40f.web.app")) {
      final uri = Uri.parse(code);
      final targetUid = uri.queryParameters['uid'] ?? "";
      final targetName = Uri.decodeComponent(uri.queryParameters['name'] ?? "Người nhận ANPAY");

      _navigateToTransfer(PaymentAccount(
        accountNumber: targetUid,
        name: targetName,
        provider: "ANPAY Internal",
        isService: false,
      ));
    } else if (code.startsWith("000201")) {
      _processVietQR(code);
    } else if (code.startsWith("http")) {
      if (await canLaunchUrl(Uri.parse(code))) {
        await launchUrl(Uri.parse(code), mode: LaunchMode.externalApplication);
      }
      _resumeScanner();
    } else {
      _showResultDialog(code);
    }
  }

  void _processVietQR(String qrCode) {
    String bankName = "Ngân hàng (VietQR)";
    if (qrCode.contains("970422")) bankName = "MB Bank";
    else if (qrCode.contains("970436")) bankName = "Vietcombank";

    _navigateToTransfer(PaymentAccount.fromBank(
      bankName: bankName,
      accountNumber: "88889999123",
      ownerName: "NGUYEN VAN DEMO",
    ));
  }

  void _navigateToTransfer(PaymentAccount account) {
    if (!mounted) {
      _isGlobalProcessing = false;
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(account: account),
      ),
    ).then((_) => _resumeScanner()); 
  }

  void _resumeScanner() {
    _isGlobalProcessing = false;

    if (mounted) {
      setState(() {
        _isScanned = false;
        _isCooldown = true;     
      });
      
      // Đảm bảo camera vẫn hoạt động
      if (widget.isActive) _startScanner();

      // Sau 2.5 giây mới cho phép quét mã tiếp theo để tránh trùng lặp mã vừa quét
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _isCooldown = false);
        }
      });
    }
  }

  void _showResultDialog(String text) {
    if (!mounted) {
      _isGlobalProcessing = false;
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Thông tin QR"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _resumeScanner(); },
            child: const Text("Quét tiếp"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.isTab ? null : AppBar(
        title: const Text("Quét mã QR"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) {
              // Kiểm tra tất cả các cờ chặn trước khi xử lý
              if (_isGlobalProcessing || _isScanned || _isCooldown) return;
              
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break; 
                }
              }
            },
            placeholderBuilder: (context, child) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          
          // Khung quét trang trí
          Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Container(height: 1.5, width: 220, color: Colors.red.withOpacity(0.8)),
              ),
            ),
          ),

          // Hiệu ứng Loading khi đang chuyển màn hình
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
