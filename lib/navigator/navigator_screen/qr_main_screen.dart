import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/qr/qr_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrMainScreen extends StatefulWidget {
  final bool isTab;
  final bool isActive;

  const QrMainScreen({super.key, this.isTab = false, this.isActive = true});

  @override
  State<QrMainScreen> createState() => QrMainScreenState();
}

class QrMainScreenState extends State<QrMainScreen> {
  int _currentIndex = 0;
  String _displayName = 'Đang tải...';
  String _walletCode = '';
  String _uri = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  Future<void> _loadQr() async {
    AppLogger.repo('QR_UI', 'Loading my QR');
    try {
      final data = await AppServices.qr.mine();
      if (!mounted) return;
      setState(() {
        _displayName = data['displayName']?.toString() ?? 'N/A';
        _walletCode = data['walletCode']?.toString() ?? '';
        _uri = data['uri']?.toString() ?? '';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyToClipboard(String text) {
    AppLogger.action('QR copy wallet code pressed', {'value': AppLogger.mask(text)});
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép mã ví AnPay')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'QR nhận tiền' : 'Quét mã QR'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !widget.isTab,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadQr,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'ANPAY',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.purple,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_uri.isNotEmpty)
                                Container(
                                  width: 260,
                                  height: 260,
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: Image.network(
                                    'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(_uri)}',
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.qr_code_2, size: 180),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                _displayName.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _walletCode,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _walletCode.isEmpty
                                    ? null
                                    : () => _copyToClipboard(_walletCode),
                                icon: const Icon(Icons.copy),
                                label: const Text('Sao chép mã ví'),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'QR chỉ chứa walletCode công khai. Tên người nhận được backend resolve lại khi người gửi quét mã.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          QRScanScreen(isTab: false, isActive: _currentIndex == 1),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded), label: 'Nhận tiền'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Quét mã'),
        ],
      ),
    );
  }
}
