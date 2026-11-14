import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/util/idempotency_key.dart';
import '../../../navigator/model/payment_account.dart';
import '../../../navigator/qr/qr_scan_screen.dart';
import '../data/lucky_money_repository.dart';
import 'lucky_money_detail_screen.dart';
import 'lucky_money_widgets.dart';

class LuckyMoneyCreateScreen extends StatefulWidget {
  final LuckyMoneyRepository? repository;
  final Future<Map<String, dynamic>> Function()? walletLoader;
  const LuckyMoneyCreateScreen({super.key, this.repository, this.walletLoader});
  @override
  State<LuckyMoneyCreateScreen> createState() => _LuckyMoneyCreateScreenState();
}

class _LuckyMoneyCreateScreenState extends State<LuckyMoneyCreateScreen> {
  LuckyMoneyRepository get _repo => widget.repository ?? AppServices.luckyMoney;
  final _form = GlobalKey<FormState>();
  final _wallet = TextEditingController(),
      _amount = TextEditingController(),
      _greeting = TextEditingController();
  String _template = 'PROSPERITY';
  int? _balance;
  String? _ownWallet, _error, _payload;
  String _key = IdempotencyKey.generate();
  bool _loadingBalance = true, _busy = false;
  bool _uncertainPrepare = false;

  @override
  void initState() {
    super.initState();
    _greeting.text = envelopeTemplates[_template]!.$3;
    _loadBalance();
  }

  @override
  void dispose() {
    _wallet.dispose();
    _amount.dispose();
    _greeting.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _loadingBalance = true;
      _error = null;
    });
    try {
      final value = await (widget.walletLoader ?? AppServices.wallet.me)();
      final balance = value['availableBalance'];
      if (balance is! num) {
        throw const FormatException('Missing available balance');
      }
      if (mounted) {
        setState(() {
          _balance = balance.toInt();
          _ownWallet = value['walletCode']?.toString().toUpperCase();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiException
              ? error.message
              : 'Không tải được số dư. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingBalance = false);
    }
  }

  int get _value => int.tryParse(_amount.text) ?? 0;

  Future<void> _scan() async {
    final account = await Navigator.of(context).push<PaymentAccount>(
      MaterialPageRoute(
        builder: (_) =>
            const QRScanScreen(isTab: false, selectRecipientOnly: true),
      ),
    );
    if (mounted && account != null) _wallet.text = account.accountNumber;
  }

  Future<void> _preview() async {
    if (_busy || _balance == null || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Xem trước phong bao',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 16),
              EnvelopeCard(
                template: _template,
                greeting: _greeting.text.trim(),
                recipient: _wallet.text.trim().toUpperCase(),
                amount: _value,
              ),
              const SizedBox(height: 16),
              const Text(
                'Phong bao có hạn 24 giờ sau khi xác nhận OTP. Nếu người nhận chưa mở, tiền sẽ tự hoàn về ví.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text('Tiếp tục xác nhận OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    await _prepare();
  }

  Future<void> _prepare() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final wallet = _wallet.text.trim().toUpperCase();
    final greeting = _greeting.text.trim();
    final payload = '$wallet|$_value|$_template|$greeting';
    if (_payload != null && _payload != payload) {
      _key = IdempotencyKey.generate();
    }
    _payload = payload;
    try {
      final envelope = await _repo.prepare(
        walletCode: wallet,
        amount: _value,
        template: _template,
        greeting: greeting,
        idempotencyKey: _key,
      );
      if (!mounted) return;
      // Keep one key for ambiguous retries and keep this form busy while the
      // envelope is open. Return to the box only after the detail screen closes,
      // so the box refreshes after OTP confirmation rather than before it.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LuckyMoneyDetailScreen(
            envelopeId: envelope.id,
            repository: _repo,
          ),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          final status = error is ApiException ? error.statusCode : null;
          _uncertainPrepare = status == null || status == 408 || status >= 500;
          _error = error is ApiException
              ? error.message
              : 'Không tạo được phong bao. Vui lòng thử lại.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gửi lì xì cá nhân')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Trao một phong bao, gửi ngàn lời chúc',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_balance == null)
              TextButton(
                onPressed: _loadingBalance ? null : _loadBalance,
                child: const Text('Tải lại số dư'),
              ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _wallet,
            enabled: !_busy && !_uncertainPrepare,
            textCapitalization: TextCapitalization.characters,
            maxLength: 32,
            decoration: InputDecoration(
              labelText: 'Mã ví người nhận',
              hintText: 'ANP…',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _busy || _uncertainPrepare ? null : _scan,
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Quét QR người nhận',
              ),
            ),
            validator: (raw) {
              final code = raw?.trim().toUpperCase() ?? '';
              if (!RegExp(r'^ANP[0-9]+$').hasMatch(code)) {
                return 'Nhập mã ví AnPay hợp lệ';
              }
              if (code == _ownWallet) {
                return 'Không thể gửi lì xì cho chính mình';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amount,
            enabled: !_busy && !_uncertainPrepare,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            decoration: const InputDecoration(
              labelText: 'Số tiền lì xì',
              suffixText: '₫',
              border: OutlineInputBorder(),
            ),
            validator: (_) => _value < 10000
                ? 'Số tiền tối thiểu 10.000 ₫'
                : _value > (_balance ?? 0)
                ? 'Số dư không đủ'
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            _loadingBalance
                ? 'Đang tải số dư…'
                : _balance == null
                ? 'Chưa tải được số dư'
                : 'Số dư khả dụng: ${luckyAmount(_balance!)}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final value in [10000, 20000, 50000, 100000])
                ActionChip(
                  label: Text(luckyAmount(value)),
                  onPressed: _busy || _uncertainPrepare
                      ? null
                      : () => setState(() => _amount.text = '$value'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Chọn phong bao',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in envelopeTemplates.entries)
                ChoiceChip(
                  label: Text(entry.value.$1),
                  selected: _template == entry.key,
                  onSelected: _busy || _uncertainPrepare
                      ? null
                      : (_) => setState(() {
                          if (_greeting.text ==
                              envelopeTemplates[_template]!.$3) {
                            _greeting.text = entry.value.$3;
                          }
                          _template = entry.key;
                        }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _greeting,
            enabled: !_busy && !_uncertainPrepare,
            minLines: 2,
            maxLines: 4,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Lời chúc',
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Viết một lời chúc cho người nhận nhé'
                : null,
          ),
          const SizedBox(height: 12),
          if (_uncertainPrepare)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Yêu cầu có thể đã được tạo. Thử lại để tiếp tục cùng phong bao, hoặc quay về hộp Đã gửi để kiểm tra.',
              ),
            ),
          FilledButton(
            onPressed: _busy || _loadingBalance || _balance == null
                ? null
                : _uncertainPrepare
                ? _prepare
                : _preview,
            child: Text(
              _busy
                  ? 'Đang tạo phong bao…'
                  : _uncertainPrepare
                  ? 'Thử lại cùng phong bao'
                  : 'Xem trước phong bao',
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
