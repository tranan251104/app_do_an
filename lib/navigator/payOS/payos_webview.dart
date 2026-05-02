import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayOSWebView extends StatefulWidget {
  final String paymentUrl;
  final String returnUrl;
  final int amount;

  const PayOSWebView({
    super.key,
    required this.paymentUrl,
    required this.returnUrl,
    required this.amount,
  });

  @override
  State<PayOSWebView> createState() => _PayOSWebViewState();
}

class _PayOSWebViewState extends State<PayOSWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessed = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
            _checkUrl(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            _checkUrl(url);
          },
          onNavigationRequest: (request) {
            _checkUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrl(String url) {
    if (_isProcessed) return;

    // 🔹 NẾU URL BẮT ĐẦU BẰNG RETURN URL (TRANG THÀNH CÔNG) -> COI LÀ XONG
    if (url.startsWith(widget.returnUrl) || url.contains("success")) {
      _isProcessed = true;
      print("✅ Payment Success Detected via URL: $url");
      Navigator.pop(context, widget.amount);
      return;
    }

    // 🔹 KIỂM TRA CÁC PARAMETER TỪ PAYOS
    try {
      final uri = Uri.parse(url);
      final status = uri.queryParameters['status']?.toUpperCase() ?? '';
      final cancel = uri.queryParameters['cancel']?.toLowerCase() ?? '';

      if (cancel == 'true' || status == 'CANCELLED') {
        _isProcessed = true;
        Navigator.pop(context, 0);
        return;
      }

      if (status == 'PAID' || status == 'SUCCESS') {
        _isProcessed = true;
        Navigator.pop(context, widget.amount);
        return;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán VietQR"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (!_isProcessed) {
              _isProcessed = true;
              Navigator.pop(context, 0);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
