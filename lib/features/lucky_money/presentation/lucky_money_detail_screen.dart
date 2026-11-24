import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../data/lucky_money_repository.dart';
import 'lucky_money_widgets.dart';
import '../../smart_otp/presentation/smart_otp_flow.dart';

class LuckyMoneyDetailScreen extends StatefulWidget {
  final String envelopeId;
  final LuckyMoneyRepository? repository;
  const LuckyMoneyDetailScreen({
    super.key,
    required this.envelopeId,
    this.repository,
  });

  @override
  State<LuckyMoneyDetailScreen> createState() => _LuckyMoneyDetailScreenState();
}

class _LuckyMoneyDetailScreenState extends State<LuckyMoneyDetailScreen> {
  LuckyMoneyRepository get _repo => widget.repository ?? AppServices.luckyMoney;
  final _otp = TextEditingController();
  LuckyEnvelope? _envelope;
  String? _error;
  bool _loading = true, _busy = false;
  DateTime? _resendAfter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final value = await _repo.get(widget.envelopeId);
      if (mounted) setState(() => _envelope = value);
    } catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _message(Object error) => error is ApiException
      ? error.message
      : 'Không thể kết nối dịch vụ lì xì. Vui lòng thử lại.';

  Future<LuckyEnvelope> _confirmWithSmartOtp() async {
    final proof=await SmartOtpFlow.authorize(context,widget.envelopeId);
    if(proof==null) throw StateError('Đã hủy xác thực Smart OTP.');
    return _repo.confirm(widget.envelopeId,proof);
  }

  Future<void> _act(String action) async {
    if(_busy) return;
    setState(() { _busy=true; _error=null; });
    try {
      final value=switch(action) {
        'confirm' => await _confirmWithSmartOtp(),
        'resend' => await _repo.resend(widget.envelopeId),
        _ => await _repo.open(widget.envelopeId),
      };
      if(mounted) setState(() => _envelope=value);
    } catch(error) {
      if(mounted) setState(() => _error=_message(error));
      try {
        final state=await _repo.get(widget.envelopeId);
        if(mounted) setState(() => _envelope=state);
      } catch(_) { /* preserve original error */ }
    } finally { if(mounted) setState(() => _busy=false); }
  }

  @override
  Widget build(BuildContext context) {
    final e = _envelope;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/lucky-money');
            }
          },
        ),
        title: const Text('Phong bao lì xì'),
        actions: [
          IconButton(
            onPressed: _busy || _loading ? null : _load,
            tooltip: 'Cập nhật trạng thái',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _busy ? () async {} : _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (e == null)
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Thử lại'),
                    ),
                  if (e != null) ...[
                    EnvelopeCard(
                      template: e.template,
                      greeting: e.greeting,
                      recipient: e.isSender
                          ? 'Gửi đến ${e.receiverName}'
                          : 'Từ ${e.senderName}',
                      amount: e.amount,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      e.statusLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Mã phong bao: ${e.reference}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.isSender
                          ? '${e.receiverName} · ${e.receiverWalletCode}'
                          : '${e.senderName} · ${e.senderWalletCode}',
                      textAlign: TextAlign.center,
                    ),
                    if (e.expiresAt != null && e.status == 'WAITING_OPEN') ...[
                      const SizedBox(height: 12),
                      Text(
                        'Hạn mở: ${luckyDate(e.expiresAt!)}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (e.openedAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Đã nhận lúc ${luckyDate(e.openedAt!)}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (e.status == 'AUTH_REQUIRED' && e.isSender) ...[
                      const SizedBox(height: 24),
                      const Text('Xác nhận phong bao bằng PIN Smart OTP trên thiết bị.'),
                      if (e.otpExpiresAt != null)
                        Text('Xác thực hết hạn: ${luckyDate(e.otpExpiresAt!)}'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _busy ? null : () => _act('resend'),
                        child: const Text('Làm mới xác thực'),
                      ),
                      FilledButton(
                        onPressed: !_busy ? () => _act('confirm') : null,
                        child: Text(
                          _busy ? 'Đang xác nhận…' : 'Xác nhận gửi lì xì',
                        ),
                      ),
                    ],
                    if (e.canOpen) ...[
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _busy ? null : () => _act('open'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB52438),
                          padding: const EdgeInsets.all(18),
                        ),
                        child: Text(_busy ? 'Đang mở…' : 'Mở lì xì'),
                      ),
                    ],
                    if (e.isSender && e.status == 'WAITING_OPEN') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Đã gửi phong bao! Tiền đang được giữ, chờ người nhận mở. Nếu chưa mở sau 24 giờ, tiền sẽ tự hoàn về số dư khả dụng.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (e.status == 'EXPIRED') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Phong bao đã hết hạn. Số tiền đã được hoàn về ví người gửi.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (e.status == 'COMPLETED') ...[
                      const SizedBox(height: 16),
                      Text(
                        e.isSender
                            ? 'Người nhận đã mở phong bao của bạn.'
                            : 'Tiền lì xì đã được cộng vào ví AnPay của bạn.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}
