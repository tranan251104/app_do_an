import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayWebView extends StatefulWidget {
  final String paymentUrl;
  final String returnUrl; // Nhận returnUrl từ bên ngoài

  const VNPayWebView({
    super.key, 
    required this.paymentUrl, 
    required this.returnUrl,
  });

  @override
  State<VNPayWebView> createState() => _VNPayWebViewState();
}

class _VNPayWebViewState extends State<VNPayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessed = false; // Cờ để đảm bảo chỉ xử lý kết quả 1 lần

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrl(url); // Kiểm tra ngay khi bắt đầu chuyển hướng
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkUrl(url); // Kiểm tra lại khi tải xong trang
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkUrl(String url) {
    // Nếu đã xử lý rồi thì không chạy lại nữa
    if (_isProcessed) return;

    // Kiểm tra nếu URL chứa returnUrl và kết quả VNPay
    if (url.contains(widget.returnUrl) && url.contains('vnp_ResponseCode')) {
      _isProcessed = true; // Đánh dấu đã xử lý
      
      final uri = Uri.parse(url);
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      final amountStr = uri.queryParameters['vnp_Amount'];

      if (responseCode == '00') {
        int amount = 0;
        if (amountStr != null) {
          amount = int.parse(amountStr) ~/ 100;
        }
        Navigator.pop(context, amount);
      } else {
        Navigator.pop(context, 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán VNPay"),
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        ],
      ),
    );
  }
}
