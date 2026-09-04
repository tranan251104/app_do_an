import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens the ANPAY DEV payment gateway served by the backend.
///
/// The page redirects to:
///   anpay://payment-result?status=success&paymentIntentId=...
/// after the backend confirms/cancels the mock payment. Because the page is
/// opened inside this WebView, the custom scheme is intercepted here; no
/// Android deep-link configuration is required for this checkout flow.
class AnPayGatewayWebView extends StatefulWidget {
  final String paymentUrl;
  final String paymentIntentId;

  const AnPayGatewayWebView({
    super.key,
    required this.paymentUrl,
    required this.paymentIntentId,
  });

  @override
  State<AnPayGatewayWebView> createState() => _AnPayGatewayWebViewState();
}

class _AnPayGatewayWebViewState extends State<AnPayGatewayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    AppLogger.repo(
      'ANPAY_GATEWAY_UI',
      'Opening ANPAY payment gateway',
      {
        'paymentIntentId': AppLogger.mask(widget.paymentIntentId),
        'urlHost': Uri.tryParse(widget.paymentUrl)?.host,
      },
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            AppLogger.repo(
              'ANPAY_GATEWAY_UI',
              'Gateway page started',
              {'url': _safeUrl(url)},
            );
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            AppLogger.success(
              'ANPAY_GATEWAY_UI',
              'Gateway page loaded',
              {'url': _safeUrl(url)},
            );
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            AppLogger.error(
              'ANPAY_GATEWAY_UI',
              'Gateway web resource failed',
              error: error.description,
              data: {
                'errorCode': error.errorCode,
                'errorType': error.errorType?.name,
                'isMainFrame': error.isForMainFrame,
              },
            );
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              AppLogger.warning(
                'ANPAY_GATEWAY_UI',
                'Blocked malformed navigation URL',
              );
              return NavigationDecision.prevent;
            }

            if (uri.scheme.toLowerCase() == 'anpay' &&
                uri.host.toLowerCase() == 'payment-result') {
              final status = uri.queryParameters['status']?.toLowerCase() ?? '';
              final returnedId = uri.queryParameters['paymentIntentId'];
              final paid = status == 'success' || status == 'paid' || status == 'completed';

              AppLogger.action(
                'ANPAY gateway returned to app',
                {
                  'status': status,
                  'paid': paid,
                  'paymentIntentId': AppLogger.mask(returnedId ?? widget.paymentIntentId),
                  'matchesCurrentIntent': returnedId == null || returnedId == widget.paymentIntentId,
                },
              );

              _finish(paid);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  String _safeUrl(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) return '<invalid-url>';
    // Do not leak the mock checkout capability token into Android Studio logs.
    return uri.replace(queryParameters: {
      for (final entry in uri.queryParameters.entries)
        entry.key: entry.key.toLowerCase() == 'token' ? '<redacted>' : entry.value,
    }).toString();
  }

  void _finish(bool paid) {
    if (_finished || !mounted) return;
    _finished = true;
    AppLogger.action(
      'ANPAY Gateway WebView finished',
      {
        'paid': paid,
        'paymentIntentId': AppLogger.mask(widget.paymentIntentId),
      },
    );
    Navigator.pop(context, paid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ANPAY Payment Gateway'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            tooltip: 'Đóng',
            icon: const Icon(Icons.close),
            onPressed: () => _finish(false),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.82),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text('Đang mở cổng thanh toán ANPAY...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
    );
  }
}
