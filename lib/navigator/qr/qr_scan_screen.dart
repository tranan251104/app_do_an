import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';

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
    if (state == AppLifecycleState.resumed) {
      _resumeScanner();
    }
  }

  void _handleScan(String code) async {
    if (_isScanned) return;
    setState(() => _isScanned = true);
    
    await _controller.stop();
    print("🔍 Quét được mã: $code");

    if (code.startsWith("000201")) {
      _processVietQR(code);
    } 
    else if (code.startsWith("http")) {
      final uri = Uri.parse(code);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      _resumeScanner();
    } 
    else {
      _showResultDialog(code);
    }
  }

  void _processVietQR(String qrCode) {
    String bankName = "Ngân hàng (VietQR)";
    
    if (qrCode.contains("970422")) bankName = "MB Bank";
    else if (qrCode.contains("970436")) bankName = "Vietcombank";
    else if (qrCode.contains("970407")) bankName = "Techcombank";

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
