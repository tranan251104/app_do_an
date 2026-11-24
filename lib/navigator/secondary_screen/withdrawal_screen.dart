import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/core/util/idempotency_key.dart';
import 'package:app_do_an/navigator/model/bank_catalog.dart';
import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/transaction_receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/features/smart_otp/presentation/smart_otp_flow.dart';

String _money(num amount) => '${NumberFormat.decimalPattern('vi').format(amount)} đ';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});
  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  List<Map<String, dynamic>> _banks = [];
  String? _selected;
  int _balance = 0;
  bool _loading = true;
  bool _busy = false;
  String? _pendingIdempotency;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final values = await Future.wait<dynamic>([
        AppServices.withdrawal.linkedBanks(),
        AppServices.wallet.me(),
      ]);
      if (!mounted) return;
      final accounts = List<Map<String, dynamic>>.from(values[0] as List);
      final wallet = Map<String, dynamic>.from(values[1] as Map);
      setState(() {
        _banks = accounts;
        _balance = (wallet['availableBalance'] as num?)?.toInt() ?? 0;
        if (!accounts.any((x) => x['id'] == _selected)) {
          _selected = accounts.isEmpty ? null : accounts.first['id']?.toString();
        }
      });
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Không tải được danh sách tài khoản ngân hàng liên kết.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addBank() async {
    final created = await showDialog<_NewBankInput>(
      context: context,
      builder: (_) => const _AddBankDialog(),
    );
    if (created == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final item = await AppServices.withdrawal.linkBank(
        bankBin: created.bank.bin,
        bankName: created.bank.name,
        accountNumber: created.number,
        accountName: created.owner,
      );
      if (!mounted) return;
      _selected = item['id']?.toString();
      _pendingIdempotency = null;
      await _load();
      _snack('Đã thêm tài khoản ngân hàng mô phỏng.');
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unlink(Map<String, dynamic> bank) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bỏ liên kết?'),
        content: Text('Bỏ ${bank['bankName']} ${bank['accountNumberMasked']} khỏi danh sách?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bỏ liên kết')),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await AppServices.withdrawal.unlinkBank(bank['id'].toString());
      _pendingIdempotency = null;
      await _load();
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _withdraw() async {
    if (_busy || _selected == null) return;
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount < 10000 || amount > 50000000) {
      _snack('Số tiền rút phải từ 10.000đ đến 50.000.000đ.');
      return;
    }
    if (amount > _balance) {
      _snack('Số dư ví không đủ.');
      return;
    }
    final bank = _banks.firstWhere((e) => e['id'] == _selected);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận rút tiền mô phỏng'),
        content: Text(
          'Rút ${_money(amount)} từ ví AnPay về ${bank['bankName']} '
          '${bank['accountNumberMasked']}?\n\n'
          'Số dư ví demo sẽ bị trừ khi xác nhận OTP. '
          'Không có tiền thật được chuyển vào ngân hàng.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tiếp tục')),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _busy = true);
    _pendingIdempotency ??= IdempotencyKey.generate();
    try {
      if(!await SmartOtpFlow.ensureActivated(context) || !mounted) return;
      final result = await AppServices.withdrawal.prepare(
        linkedBankAccountId: _selected!,
        amount: amount,
        note: _note.text,
        idempotencyKey: _pendingIdempotency,
      );
      if (!mounted) return;
      _pendingIdempotency = null;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WithdrawalOtpScreen(prepared: result)),
      );
      if (mounted) await _load();
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Không tạo được yêu cầu rút tiền. Kiểm tra mạng và thử lại.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Rút tiền về ngân hàng')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Số dư khả dụng của ví AnPay'),
                          const SizedBox(height: 6),
                          Text(_money(_balance),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tài khoản ngân hàng của tôi',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          if (_banks.isEmpty)
                            const Text('Chưa có tài khoản liên kết. Hãy thêm ngân hàng trước khi rút tiền.'),
                          for (final bank in _banks)
                            RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              value: bank['id'].toString(),
                              groupValue: _selected,
                              title: Text('${bank['bankName']} • ${bank['accountNumberMasked']}'),
                              subtitle: Text(bank['accountName']?.toString() ?? ''),
                              secondary: IconButton(
                                tooltip: 'Bỏ liên kết',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: _busy ? null : () => _unlink(bank),
                              ),
                              onChanged: _busy ? null : (v) => setState(() {
                                _selected = v;
                                _pendingIdempotency = null;
                              }),
                            ),
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _addBank,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm ngân hàng liên kết'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _amount,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'Số tiền rút (VND)', hintText: '300000'),
                            onChanged: (_) => _pendingIdempotency = null,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _note,
                            maxLength: 300,
                            decoration: const InputDecoration(labelText: 'Ghi chú (tùy chọn)'),
                            onChanged: (_) => _pendingIdempotency = null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      'ĐỒ ÁN MÔ PHỎNG: tài khoản ngân hàng chỉ được bạn tự khai báo, '
                      'chưa xác minh chính chủ với ngân hàng. Khi OTP đúng, hệ thống '
                      'chỉ trừ tiền ảo trong ví AnPay, KHÔNG ghi Có vào ngân hàng thật.',
                      style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _selected == null || _busy ? null : _withdraw,
                    style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                    child: _busy ? const CircularProgressIndicator() : const Text('RÚT TIỀN'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _NewBankInput {
  final BankOption bank;
  final String number;
  final String owner;
  const _NewBankInput(this.bank, this.number, this.owner);
}

class _AddBankDialog extends StatefulWidget {
  const _AddBankDialog();
  @override
  State<_AddBankDialog> createState() => _AddBankDialogState();
}

class _AddBankDialogState extends State<_AddBankDialog> {
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _owner = TextEditingController();
  String _bankBin = bankCatalog.first.bin;
  bool _confirmOwn = false;

  @override
  void dispose() {
    _number.dispose();
    _owner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Liên kết ngân hàng mô phỏng'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: _bankBin,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Ngân hàng'),
              items: bankCatalog.map((b) => DropdownMenuItem(value: b.bin, child: Text(b.name))).toList(),
              onChanged: (v) => setState(() => _bankBin = v ?? _bankBin),
            ),
            TextFormField(
              controller: _number,
              decoration: const InputDecoration(labelText: 'Số tài khoản ngân hàng'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(20)],
              validator: (v) => RegExp(r'^\d{6,20}$').hasMatch(v?.trim() ?? '') ? null : 'Nhập 6–20 chữ số',
            ),
            TextFormField(
              controller: _owner,
              maxLength: 160,
              decoration: const InputDecoration(labelText: 'Tên chủ tài khoản'),
              validator: (v) => (v?.trim().isNotEmpty ?? false) ? null : 'Nhập tên chủ tài khoản',
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmOwn,
              onChanged: (v) => setState(() => _confirmOwn = v == true),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Tôi xác nhận đây là tài khoản của tôi (chế độ demo).',
                  style: TextStyle(fontSize: 12)),
            ),
            const Text('AnPay không xác minh thông tin với ngân hàng thật.',
                style: TextStyle(fontSize: 12, color: Colors.deepPurple)),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          onPressed: !_confirmOwn ? null : () {
            if (!(_form.currentState?.validate() ?? false)) return;
            final bank = bankCatalog.firstWhere((b) => b.bin == _bankBin);
            Navigator.pop(context, _NewBankInput(bank, _number.text.trim(), _owner.text.trim()));
          },
          child: const Text('Liên kết demo'),
        ),
      ],
    );
  }
}

class WithdrawalOtpScreen extends StatefulWidget {
  final Map<String, dynamic> prepared;
  const WithdrawalOtpScreen({super.key, required this.prepared});
  @override
  State<WithdrawalOtpScreen> createState() => _WithdrawalOtpScreenState();
}

class _WithdrawalOtpScreenState extends State<WithdrawalOtpScreen> {
  final _otp = TextEditingController();
  bool _busy = false;
  bool _resending = false;
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.prepared;
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  String get _txId => _data['transactionId'].toString();

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _finish(Map<String, dynamic> result) {
    if (result['status'] == 'COMPLETED') {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => _WithdrawalResultScreen(data: result),
      ));
    } else if (result['status'] == 'FAILED') {
      _message('Rút tiền mô phỏng thất bại; ví AnPay không bị trừ.');
    } else {
      _message('Trạng thái giao dịch: ${result['status']}');
    }
  }

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy=true);
    try {
      final proof=await SmartOtpFlow.authorize(context,_txId);
      if(!mounted || proof==null) return;
      final result=await AppServices.withdrawal.confirm(_txId,proof);
      if(mounted) _finish(result);
    } on ApiException catch(e) { _message(e.message); }
    catch(_) { _message('Không xác thực được giao dịch. Hãy kiểm tra trạng thái.'); }
    finally { if(mounted) setState(() => _busy=false); }
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    try {
      final result = await AppServices.withdrawal.resendOtp(_txId);
      if (!mounted) return;
      setState(() => _data = result);
      _message('Đã tạo lại yêu cầu Smart OTP.');
    } on ApiException catch (e) {
      _message(e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _refresh() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result = await AppServices.withdrawal.get(_txId);
      if (!mounted) return;
      setState(() => _data = result);
      _finish(result);
    } on ApiException catch (e) {
      _message(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    if (_busy) return;
    final accepted = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Hủy yêu cầu rút tiền?'),
      content: const Text('Yêu cầu chưa được xác nhận OTP, nên ví vẫn chưa bị trừ.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Giữ lại')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hủy yêu cầu')),
      ],
    ));
    if (!mounted || accepted != true) return;
    setState(() => _busy = true);
    try {
      final result = await AppServices.withdrawal.cancel(_txId);
      if (!mounted) return;
      if (result['status'] == 'CANCELLED') {
        Navigator.pop(context);
      } else {
        _message('Trạng thái giao dịch: ${result['status']}');
      }
    } on ApiException catch (e) {
      _message(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart OTP rút tiền')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Nhập PIN Smart OTP để xác thực yêu cầu rút tiền mô phỏng.'),
        const SizedBox(height: 14),
        Text('Số tiền: ${_money((_data['amount'] as num?) ?? 0)}'),
        Text('Ngân hàng: ${_data['bankName'] ?? ''}'),
        Text('STK: ${_data['accountNumberMasked'] ?? ''}'),
        const SizedBox(height: 24),
          FilledButton(onPressed: _busy ? null : _confirm,
              child: _busy ? const CircularProgressIndicator() : const Text('XÁC NHẬN RÚT TIỀN')),
          TextButton(onPressed: _resending ? null : _resend,
              child: Text(_resending ? 'Đang làm mới...' : 'Làm mới Smart OTP')),
          OutlinedButton.icon(onPressed: _busy ? null : _refresh,
              icon: const Icon(Icons.refresh), label: const Text('Kiểm tra trạng thái')),
          TextButton(onPressed: _busy ? null : _cancel,
              child: const Text('Hủy yêu cầu rút tiền')),
          const SizedBox(height: 16),
          const Text('Giao dịch demo chỉ trừ tiền ảo trong Neon, không rút tiền thật về ngân hàng.',
              style: TextStyle(fontSize: 12, color: Colors.deepPurple), textAlign: TextAlign.center),
        ]),
    );
  }
}

class _WithdrawalResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const _WithdrawalResultScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    final id = data['transactionId']?.toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả rút tiền')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.check_circle, size: 82, color: Colors.green),
          const SizedBox(height: 12),
          const Text('Rút tiền mô phỏng thành công',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(_money((data['amount'] as num?) ?? 0),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 27, color: Colors.deepPurple)),
          const SizedBox(height: 20),
          Text('Ngân hàng: ${data['bankName']}'),
          Text('Tài khoản: ${data['accountName']} • ${data['accountNumberMasked']}'),
          Text('Mã giao dịch: ${data['reference']}'),
          Text('Mã mô phỏng: ${data['providerReference'] ?? '—'}'),
          const SizedBox(height: 18),
          const Text('Không có tiền thật nào được chuyển tới ngân hàng.',
              style: TextStyle(color: Colors.deepPurple)),
          const Spacer(),
          if (id != null)
            OutlinedButton.icon(
              icon: const Icon(Icons.receipt_long),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => TransactionReceiptScreen(
                    transactionId: id,
                    data: {
                      'status': 'COMPLETED', 'type': 'WITHDRAWAL', 'direction': 'OUT',
                      'amount': data['amount'], 'counterpartyName': data['accountName'],
                      'bankName': data['bankName'], 'simulated': true,
                      'providerReference': data['providerReference'],
                    },
                  ))),
              label: const Text('Xem biên lai'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context, rootNavigator: true)
                .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const TabbarScreen()), (_) => false),
            child: const Text('Về trang chủ'),
          ),
        ]),
      ),
    );
  }
}
