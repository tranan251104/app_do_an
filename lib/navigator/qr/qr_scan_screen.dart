import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/service/scanner_service.dart'; // 👈 Import service

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
  // 🔹 Sử dụng chung một bộ điều khiển duy nhất
  MobileScannerController get _controller => ScannerService.instance;
  
  bool _isScanned = false;

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
    await ScannerService.start();
  }

  Future<void> _stopScanner() async {
    await ScannerService.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // ⚠️ Không dispose controller ở đây vì nó là singleton dùng chung
    _stopScanner();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.resumed) {
      _startScanner();
    } else {
      _stopScanner();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      // Nếu màn hình này không còn là màn hình chính (ví dụ bị Navigator.push đè lên)
      if (route.isCurrent && widget.isActive) {
        _startScanner();
      } else {
        _stopScanner();
      }
    }
  }

  void _handleScan(String code) async {
    if (_isScanned) return;
    setState(() => _isScanned = true);
    await _stopScanner();

    if (!mounted) return;

    if (code.contains("app-do-an-ae40f.web.app")) {
      final uri = Uri.parse(code);
      final targetUid = uri.queryParameters['uid'] ?? "";
      final targetName = Uri.decodeComponent(uri.queryParameters['name'] ?? "Người nhận ANPAY");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransferMoneyFormScreen(
            account: PaymentAccount(
              accountNumber: targetUid,
              name: targetName,
              provider: "ANPAY Internal",
              isService: false,
            ),
          ),
        ),
      ).then((_) => _resumeScanner());
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(
          account: PaymentAccount.fromBank(
            bankName: bankName,
            accountNumber: "88889999123",
            ownerName: "NGUYEN VAN DEMO",
          ),
        ),
      ),
    ).then((_) => _resumeScanner());
  }

  void _resumeScanner() {
    if (mounted) {
      setState(() => _isScanned = false);
      if (widget.isActive) _startScanner();
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
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break;
                }
              }
            },
            placeholderBuilder: (context, child) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
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
