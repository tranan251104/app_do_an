import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WalletNumberScreen extends StatefulWidget {
  final bool finishToLogin;

  const WalletNumberScreen({
    super.key,
    this.finishToLogin = true,
  });

  @override
  State<WalletNumberScreen> createState() => _WalletNumberScreenState();
}

class _WalletNumberScreenState extends State<WalletNumberScreen> {
  final _controller = TextEditingController();
  bool _checking = false;
  bool _submitting = false;
  bool? _available;
  String? _checkedCode;
  String? _message;

  static const _suggestions = <String>[
    '686868686',
    '888888888',
    '123456789',
    '686886868',
    '111122222',
    '246824688',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final digits = _controller.text.trim();
    if (digits.length != 9) {
      setState(() {
        _available = null;
        _checkedCode = null;
        _message = 'Vui lòng nhập đúng 9 chữ số.';
      });
      return;
    }

    AppLogger.action(
      'WALLET_NUMBER check pressed',
      {'candidate': 'ANP***${digits.substring(6)}'},
    );
    setState(() {
      _checking = true;
      _message = null;
    });
    try {
      final data = await AppServices.wallet.checkAccountNumber(digits);
      if (!mounted) return;
      setState(() {
        _available = data['available'] == true;
        _checkedCode = data['walletCode']?.toString();
        _message = _available == true
            ? 'Số tài khoản này đang khả dụng.'
            : 'Số tài khoản này đã có người sử dụng.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _available = null;
        _checkedCode = null;
        _message = e.message;
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _claim() async {
    final digits = _controller.text.trim();
    if (_available != true || _checkedCode == null || digits.length != 9) {
      await _check();
      if (!mounted || _available != true) return;
    }

    AppLogger.action(
      'WALLET_NUMBER claim pressed',
      {'candidate': 'ANP***${digits.substring(6)}'},
    );
    setState(() => _submitting = true);
    try {
      final wallet = await AppServices.wallet.claimAccountNumber(digits);
      if (!mounted) return;
      await _finish(wallet['walletCode']?.toString() ?? 'ANP$digits');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _available = e.code == 'WALLET_NUMBER_TAKEN' ? false : _available;
        _message = e.message;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _random() async {
    AppLogger.action('WALLET_NUMBER random pressed');
    setState(() => _submitting = true);
    try {
      final wallet = await AppServices.wallet.assignRandomAccountNumber();
      if (!mounted) return;
      await _finish(wallet['walletCode']?.toString() ?? '');
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _finish(String walletCode) async {
    AppLogger.success(
      'WALLET_NUMBER_UI',
      'Account number setup completed',
      {'walletCode': walletCode.length >= 6 ? '${walletCode.substring(0, 3)}***${walletCode.substring(walletCode.length - 3)}' : '***'},
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 54),
        title: const Text('Tạo số tài khoản thành công'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Số tài khoản AnPay của bạn là:'),
            const SizedBox(height: 12),
            SelectableText(
              walletCode,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bạn có thể dùng số này để nhận tiền từ các ví AnPay khác.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('TIẾP TỤC'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (widget.finishToLogin) {
      // Registration used a temporary authenticated session only to finish
      // onboarding. The product rule requires a fresh login before entering
      // the main app.
      await NotificationService.unregisterCurrentDevice();
      await AppServices.auth.logout();
      if (!mounted) return;
      context.go('/welcome');
    } else {
      context.go('/main?fromLogin=true');
    }
  }

  void _selectSuggestion(String digits) {
    _controller.text = digits;
    setState(() {
      _available = null;
      _checkedCode = null;
      _message = null;
    });
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final busy = _checking || _submitting;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn số tài khoản AnPay'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade500, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 34),
                    SizedBox(height: 14),
                    Text(
                      'Số tài khoản của riêng bạn',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dùng số ANP này để nhận và chuyển tiền nội bộ. Mỗi số chỉ thuộc về một tài khoản.',
                      style: TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Chọn số đẹp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Nhập 9 chữ số bạn muốn. Hệ thống sẽ kiểm tra chống trùng trước khi đăng ký.',
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                enabled: !busy,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (_) {
                  if (_available != null || _message != null) {
                    setState(() {
                      _available = null;
                      _checkedCode = null;
                      _message = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  prefixText: 'ANP  ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.deepPurple),
                  hintText: '686868686',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  suffixIcon: _checking
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          onPressed: busy ? null : _check,
                          tooltip: 'Kiểm tra',
                          icon: const Icon(Icons.search),
                        ),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _available == true
                          ? Icons.check_circle
                          : _available == false
                              ? Icons.cancel
                              : Icons.info_outline,
                      color: _available == true
                          ? Colors.green
                          : _available == false
                              ? Colors.red
                              : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_message!)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestions
                    .map(
                      (digits) => ActionChip(
                        label: Text('ANP$digits'),
                        onPressed: busy ? null : () => _selectSuggestion(digits),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : _claim,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ĐĂNG KÝ SỐ NÀY', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('HOẶC', style: TextStyle(color: Colors.black45, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.casino_outlined, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Text('Nhận số ngẫu nhiên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nếu không cần số đẹp, Backend sẽ tự sinh một mã ANP gồm 9 chữ số và bảo đảm không cấp trùng.',
                      style: TextStyle(color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: busy ? null : _random,
                        child: const Text('NHẬN SỐ NGẪU NHIÊN'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
