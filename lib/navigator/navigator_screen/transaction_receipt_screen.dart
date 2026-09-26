import 'dart:ui' as ui;
import 'package:app_do_an/core/app_services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TransactionReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? transactionId;
  const TransactionReceiptScreen({
    super.key,
    required this.data,
    this.transactionId,
  });
  @override
  State<TransactionReceiptScreen> createState() =>
      _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> {
  final _receiptKey = GlobalKey();
  bool _busy = false;
  Map<String, dynamic>? _verifiedData;
  bool _loading = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final detail = await AppServices.transaction.get(widget.transactionId!);
      if (!mounted) return;
      setState(() => _verifiedData = {...detail, 'id': widget.transactionId});
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _mobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  String _money(num value) => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  ).format(value);

  Future<void> _export({required bool share}) async {
    if (_busy || _loading || _loadFailed) return;
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary =
          _receiptKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('Could not render receipt');
      final name =
          'AnPay-bien-lai-${DateTime.now().millisecondsSinceEpoch}.png';
      final file = XFile.fromData(
        bytes.buffer.asUint8List(),
        name: name,
        mimeType: 'image/png',
      );
      if (share || _mobile) {
        await Share.shareXFiles(
          [file],
          subject: 'Biên lai AnPay',
          sharePositionOrigin: origin,
        );
      } else if (kIsWeb) {
        await file.saveTo(name);
      } else {
        final location = await getSaveLocation(
          suggestedName: name,
          acceptedTypeGroups: const [
            XTypeGroup(
              label: 'Ảnh PNG',
              extensions: ['png'],
              uniformTypeIdentifiers: ['public.png'],
            ),
          ],
        );
        if (location == null) return;
        await file.saveTo(location.path);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã lưu biên lai.')));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không xuất được biên lai. Vui lòng thử lại.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _loadFailed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Biên lai giao dịch')),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Chưa tải được thông tin biên lai.'),
                    TextButton(
                      onPressed: _loadDetail,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
        ),
      );
    }
    final data = _verifiedData ?? widget.data;
    final status = data['status']?.toString().toUpperCase() ?? '';
    final completed = status == 'COMPLETED';
    final statusLabel =
        const {
          'COMPLETED': 'Giao dịch thành công',
          'PENDING': 'Đang xử lý',
          'OTP_REQUIRED': 'Chờ xác nhận OTP',
          'FAILED': 'Giao dịch thất bại',
          'CANCELLED': 'Giao dịch đã hủy',
          'CANCELED': 'Giao dịch đã hủy',
        }[status] ??
        'Trạng thái chưa xác định';
    final incoming = const [
      'IN',
      'CREDIT',
    ].contains(data['direction']?.toString().toUpperCase());
    final date = DateTime.tryParse(
      (data['completedAt'] ?? data['createdAt'])?.toString() ?? '',
    )?.toLocal();
    final color = completed
        ? Colors.green
        : (status == 'PENDING' || status == 'OTP_REQUIRED')
        ? Colors.orange
        : Colors.red;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0F8),
      appBar: AppBar(title: const Text('Biên lai giao dịch')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: RepaintBoundary(
              key: _receiptKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'AnPay',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: .7, end: 1),
                      duration: const Duration(milliseconds: 350),
                      builder: (_, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Icon(
                        completed
                            ? Icons.check_circle
                            : (status == 'PENDING' || status == 'OTP_REQUIRED')
                            ? Icons.schedule
                            : Icons.info,
                        color: color,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      statusLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _money(data['amount'] as num? ?? 0),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    if (data['counterpartyName'] != null)
                      _row(
                        incoming ? 'Người gửi' : 'Người nhận / dịch vụ',
                        data['counterpartyName'],
                      ),
                    if (data['counterpartyAccount'] != null)
                      _row('Số tài khoản', data['counterpartyAccount']),
                    if (data['bankName'] != null)
                      _row('Ngân hàng', data['bankName']),
                    if (date != null)
                      _row(
                        'Thời gian',
                        DateFormat('HH:mm:ss · dd/MM/yyyy').format(date),
                      )
                    else if (data['displayTime'] != null)
                      _row('Thời gian', data['displayTime']),
                    if (data['fee'] is num)
                      _row('Phí giao dịch', _money(data['fee'] as num)),
                    if (data['description'] != null)
                      _row('Nội dung', data['description']),
                    if (data['reference'] != null || data['id'] != null)
                      _row('Mã giao dịch', data['reference'] ?? data['id']),
                    if (data['providerReference'] != null)
                      _row('Mã đối soát', data['providerReference']),
                    const Divider(),
                    const SizedBox(height: 12),
                    if (data['simulated'] == true)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'GIAO DỊCH MÔ PHỎNG\nKhông xác nhận chuyển tiền thật đến ngân hàng bên ngoài.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Text(
                      'Biên lai điện tử AnPay',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mobile)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Chọn ứng dụng nhận hoặc tùy chọn lưu trong bảng chia sẻ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (!_mobile)
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _export(share: false),
                      icon: const Icon(Icons.download),
                      label: const Text('Lưu ảnh'),
                    ),
                  if (kIsWeb || defaultTargetPlatform != TargetPlatform.linux)
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _export(share: true),
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.ios_share),
                      label: Text(_mobile ? 'Lưu / chia sẻ ảnh' : 'Chia sẻ'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, Object? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
