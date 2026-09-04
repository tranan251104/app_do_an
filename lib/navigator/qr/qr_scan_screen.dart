import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/service/scanner_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScanScreen extends StatefulWidget {
  final bool isTab;
  final bool isActive;

  const QRScanScreen({super.key, this.isTab = true, this.isActive = true});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with WidgetsBindingObserver {
  MobileScannerController get _controller => ScannerService.instance;

  static bool _isGlobalProcessing = false;
  bool _isScanned = false;
  bool _isCooldown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) _startScanner();
  }

  @override
  void didUpdateWidget(QRScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _startScanner() : _stopScanner();
    }
  }

  Future<void> _startScanner() async {
    AppLogger.repo('QR_SCAN', 'Start scanner');
    if (widget.isActive) await ScannerService.start();
  }

  Future<void> _stopScanner() => ScannerService.stop();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

  Future<void> _handleScan(String code) async {
    AppLogger.action('QR code scanned', {'codeLength': code.length});
    if (_isGlobalProcessing || _isScanned || _isCooldown || !mounted) return;

    _isGlobalProcessing = true;
    setState(() => _isScanned = true);

    try {
      if (code.startsWith('anpay://') || code.contains('walletCode=') || code.toUpperCase().startsWith('ANP')) {
        final resolved = await AppServices.qr.resolve(code);
        final canTransfer = resolved['canTransfer'] == true;
        if (!canTransfer) throw const ApiException(code: 'WALLET_UNAVAILABLE', message: 'Ví người nhận hiện không thể nhận tiền');

        final account = PaymentAccount(
          accountNumber: resolved['walletCode']?.toString() ?? '',
          name: resolved['displayName']?.toString() ?? 'Người nhận AnPay',
          provider: 'ANPAY Internal',
        );
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TransferMoneyFormScreen(account: account)),
        );
        _resumeScanner();
        return;
      }

      if (code.startsWith('000201')) {
        _showResultDialog(
          'Đã nhận VietQR. Backend hiện chưa có API ngân hàng để xác minh tên chủ tài khoản, vì vậy AnPay không hiển thị tên giả và chưa cho phép chuyển tiền từ mã này.',
        );
        return;
      }

      if (code.startsWith('http')) {
        final uri = Uri.tryParse(code);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        _resumeScanner();
        return;
      }

      _showResultDialog(code);
    } on ApiException catch (e) {
      _showResultDialog(e.message);
    } catch (e) {
      _showResultDialog('Không thể xử lý QR: $e');
    }
  }

  void _resumeScanner() {
    AppLogger.action('QR scanner resume pressed');
    _isGlobalProcessing = false;
    if (!mounted) return;
    setState(() {
      _isScanned = false;
      _isCooldown = true;
    });
    if (widget.isActive) _startScanner();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _isCooldown = false);
    });
  }

  void _showResultDialog(String text) {
    if (!mounted) {
      _isGlobalProcessing = false;
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thông tin QR'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _resumeScanner();
            },
            child: const Text('Quét tiếp'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.isTab
          ? null
          : AppBar(
              title: const Text('Quét mã QR'),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            fit: BoxFit.cover,
            onDetect: (capture) {
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
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 2),
                borderRadius: BorderRadius.circular(24),
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
