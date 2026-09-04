import 'dart:async';

import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TollServiceScreen extends StatefulWidget {
  const TollServiceScreen({super.key});

  @override
  State<TollServiceScreen> createState() => _TollServiceScreenState();
}

class _TollServiceScreenState extends State<TollServiceScreen> {
  String? _provider;
  String? _accountCode;
  String? _vehiclePlate;
  int _demoBalance = 0;
  final List<_EtcDemoTransaction> _topupHistory = [];

  bool get _hasLinkedAccount =>
      _provider != null && _accountCode != null && _vehiclePlate != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text('Thu phí không dừng'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 18),
          const Text(
            'Dịch vụ chính',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PrimaryActionCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Nạp tiền ETC',
                  subtitle: 'Nạp vào tài khoản thu phí',
                  onTap: _openTopup,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryActionCard(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Quản lý',
                  subtitle: 'Liên kết và quản lý tài khoản',
                  onTap: _openAccountManager,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Tiện ích ETC',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _UtilityTile(
            icon: Icons.directions_car_outlined,
            title: 'Phương tiện',
            subtitle: _hasLinkedAccount
                ? 'Quản lý biển số $_vehiclePlate'
                : 'Quản lý phương tiện sử dụng ETC',
            onTap: _showVehicles,
          ),
          _UtilityTile(
            icon: Icons.route_outlined,
            title: 'Lịch sử qua trạm',
            subtitle: 'Tra cứu các lượt xe qua trạm thu phí',
            onTap: _showTollHistory,
          ),
          _UtilityTile(
            icon: Icons.receipt_long_outlined,
            title: 'Lịch sử nạp tiền',
            subtitle: _topupHistory.isEmpty
                ? 'Tra cứu các lần nạp tiền cho tài khoản ETC'
                : '${_topupHistory.length} giao dịch demo trong phiên này',
            onTap: _showTopupHistory,
          ),
          _UtilityTile(
            icon: Icons.support_agent_outlined,
            title: 'Hỗ trợ ETC',
            subtitle: 'Thông tin hỗ trợ và giải đáp dịch vụ',
            onTap: _showSupport,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Chế độ demo: luồng nạp tiền có đủ các bước nhập thông tin, xác nhận, OTP, xử lý và biên lai nhưng không gọi backend ETC và không trừ tiền thật.',
                    style: TextStyle(fontSize: 13, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    final money = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.toll, color: Colors.white, size: 28),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản ETC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Quản lý và nạp tiền ngay trên AnPay',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_hasLinkedAccount) ...[
            Text(
              '$_provider • $_vehiclePlate',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mã tài khoản: $_accountCode',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            const Text(
              'Số dư ETC demo',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${money.format(_demoBalance)}đ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            const Text(
              'Chưa liên kết tài khoản ETC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Liên kết VETC hoặc ePass để quản lý thuận tiện hơn.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openTopup() async {
    AppLogger.action('ETC demo topup opened', {
      'linkedAccount': _hasLinkedAccount,
      'provider': _provider,
    });

    final transaction = await Navigator.push<_EtcDemoTransaction>(
      context,
      MaterialPageRoute(
        builder: (_) => _EtcTopupFlowScreen(
          initialProvider: _provider,
          initialAccountCode: _accountCode,
          initialVehiclePlate: _vehiclePlate,
        ),
      ),
    );

    if (!mounted || transaction == null) return;

    setState(() {
      _provider = transaction.provider;
      _accountCode = transaction.accountCode;
      _vehiclePlate = transaction.vehiclePlate;
      _demoBalance += transaction.amount;
      _topupHistory.insert(0, transaction);
    });

    AppLogger.success('ETC_UI', 'Demo ETC topup completed', {
      'provider': transaction.provider,
      'amount': transaction.amount,
      'transactionId': transaction.transactionId,
    });
  }

  Future<void> _openAccountManager() async {
    final result = await showModalBottomSheet<_EtcAccountResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EtcAccountManagerSheet(
        initialProvider: _provider,
        initialAccountCode: _accountCode,
        initialVehiclePlate: _vehiclePlate,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _provider = result.provider;
      _accountCode = result.accountCode;
      _vehiclePlate = result.vehiclePlate;
    });

    AppLogger.success('ETC_UI', 'Demo ETC account linked', {
      'provider': result.provider,
      'vehiclePlate': result.vehiclePlate,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu liên kết ETC trong phiên demo này.'),
      ),
    );
  }

  void _showVehicles() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phương tiện ETC',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_hasLinkedAccount)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.shade50,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vehiclePlate!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('$_provider • Tài khoản $_accountCode'),
                          ],
                        ),
                      ),
                      const Chip(label: Text('Đã liên kết')),
                    ],
                  ),
                )
              else
                const _EmptyDemoState(
                  icon: Icons.directions_car_outlined,
                  title: 'Chưa có phương tiện',
                  message: 'Hãy liên kết tài khoản ETC ở mục Quản lý.',
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTollHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final rows = _hasLinkedAccount
            ? const [
                ('Trạm Pháp Vân - Cầu Giẽ', '28/08/2026 • 08:42', 35000),
                ('Trạm Hà Nội - Hải Phòng', '26/08/2026 • 17:15', 45000),
                ('Trạm Cầu Giẽ - Ninh Bình', '24/08/2026 • 10:08', 30000),
              ]
            : const <(String, String, int)>[];
        final money = NumberFormat('#,###');
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử qua trạm',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dữ liệu mẫu phục vụ demo giao diện.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                if (rows.isEmpty)
                  const _EmptyDemoState(
                    icon: Icons.route_outlined,
                    title: 'Chưa có dữ liệu',
                    message: 'Liên kết ETC để xem lịch sử qua trạm demo.',
                  )
                else
                  ...rows.map(
                    (row) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade50,
                        child: const Icon(Icons.toll, color: Colors.purple),
                      ),
                      title: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(row.$2),
                      trailing: Text(
                        '-${money.format(row.$3)}đ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTopupHistory() {
    final money = NumberFormat('#,###');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lịch sử nạp tiền',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Các giao dịch demo chỉ tồn tại trong phiên chạy ứng dụng.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              if (_topupHistory.isEmpty)
                const _EmptyDemoState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Chưa có giao dịch nạp',
                  message: 'Thực hiện một giao dịch nạp ETC để xem tại đây.',
                )
              else
                ..._topupHistory.map(
                  (tx) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      child: const Icon(Icons.check, color: Colors.green),
                    ),
                    title: Text(
                      '+${money.format(tx.amount)}đ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${tx.provider} • ${tx.vehiclePlate}\n${DateFormat('dd/MM/yyyy • HH:mm').format(tx.createdAt)}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      tx.transactionId.substring(tx.transactionId.length - 6),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupport() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hỗ trợ ETC',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              const _SupportTile(
                icon: Icons.help_outline,
                title: 'Câu hỏi thường gặp',
                subtitle: 'Nạp tiền, liên kết tài khoản, lỗi giao dịch',
              ),
              const _SupportTile(
                icon: Icons.headset_mic_outlined,
                title: 'CSKH AnPay',
                subtitle: 'Demo hotline: 1900 0000',
              ),
              const _SupportTile(
                icon: Icons.email_outlined,
                title: 'Gửi yêu cầu hỗ trợ',
                subtitle: 'Tạo yêu cầu xử lý giao dịch ETC',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtcTopupFlowScreen extends StatefulWidget {
  final String? initialProvider;
  final String? initialAccountCode;
  final String? initialVehiclePlate;

  const _EtcTopupFlowScreen({
    this.initialProvider,
    this.initialAccountCode,
    this.initialVehiclePlate,
  });

  @override
  State<_EtcTopupFlowScreen> createState() => _EtcTopupFlowScreenState();
}

class _EtcTopupFlowScreenState extends State<_EtcTopupFlowScreen> {
  late String _provider;
  late final TextEditingController _accountController;
  late final TextEditingController _plateController;
  late final TextEditingController _amountController;
  late final TextEditingController _otpController;

  int _step = 0;
  int _amount = 0;
  bool _lookupLoading = false;
  bool _accountVerified = false;
  bool _processing = false;
  String? _verifiedName;
  _EtcDemoTransaction? _completedTransaction;

  static const List<int> _quickAmounts = [100000, 200000, 500000, 1000000];

  @override
  void initState() {
    super.initState();
    _provider = widget.initialProvider ?? 'VETC';
    _accountController = TextEditingController(text: widget.initialAccountCode);
    _plateController = TextEditingController(text: widget.initialVehiclePlate);
    _amountController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _plateController.dispose();
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  int get _parsedAmount =>
      int.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', ''),
      ) ??
      0;

  void _setAmount(int amount) {
    setState(() {
      _amount = amount;
      _amountController.text = amount.toString();
    });
  }

  Future<void> _verifyAccountAndContinue() async {
    final account = _accountController.text.trim();
    final plate = _plateController.text.trim().toUpperCase();
    final amount = _parsedAmount;

    if (account.isEmpty || plate.isEmpty) {
      _showMessage('Vui lòng nhập tài khoản ETC và biển số xe.');
      return;
    }
    if (amount < 10000) {
      _showMessage('Số tiền nạp tối thiểu là 10.000đ.');
      return;
    }

    setState(() => _lookupLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _lookupLoading = false;
      _accountVerified = true;
      _verifiedName = 'NGUYEN VAN AN';
      _step = 1;
      _amount = amount;
      _plateController.text = plate;
    });
  }

  void _goToOtp() {
    setState(() => _step = 2);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp != '123456') {
      _showMessage('OTP demo chưa đúng. Hãy nhập 123456.');
      return;
    }

    setState(() {
      _step = 3;
      _processing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final now = DateTime.now();
    final tx = _EtcDemoTransaction(
      provider: _provider,
      accountCode: _accountController.text.trim(),
      vehiclePlate: _plateController.text.trim().toUpperCase(),
      amount: _amount,
      transactionId: 'ETC${now.millisecondsSinceEpoch.toString().substring(4)}',
      createdAt: now,
    );

    setState(() {
      _processing = false;
      _completedTransaction = tx;
      _step = 4;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmExit() async {
    if (_step == 4) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Hủy giao dịch?'),
            content: const Text(
              'Thông tin giao dịch ETC đang nhập sẽ không được lưu.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('TIẾP TỤC'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('HỦY GIAO DỊCH'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 4,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _confirmExit();
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FA),
        appBar: AppBar(
          title: const Text('Nạp tiền ETC'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            if (_step < 4) _buildStepHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_step) {
                  0 => _buildInputStep(),
                  1 => _buildConfirmStep(),
                  2 => _buildOtpStep(),
                  3 => _buildProcessingStep(),
                  _ => _buildSuccessStep(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    const titles = ['Thông tin', 'Xác nhận', 'OTP', 'Xử lý'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: List.generate(titles.length, (index) {
          final active = index <= _step;
          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: active
                      ? Colors.purple
                      : Colors.grey.shade300,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      color: active ? Colors.purple : Colors.grey,
                    ),
                  ),
                ),
                if (index < titles.length - 1)
                  Container(
                    width: 10,
                    height: 1,
                    color: active
                        ? Colors.purple.shade200
                        : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputStep() {
    final formatter = NumberFormat('#,###');
    return ListView(
      key: const ValueKey('input'),
      padding: const EdgeInsets.all(16),
      children: [
        _DemoBanner(
          text:
              'Demo tra cứu tài khoản ETC: ứng dụng sẽ giả lập phản hồi từ $_provider trước khi sang bước xác nhận.',
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Thông tin tài khoản ETC',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _provider,
                decoration: const InputDecoration(
                  labelText: 'Nhà cung cấp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.toll_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'VETC', child: Text('VETC')),
                  DropdownMenuItem(value: 'ePass', child: Text('ePass')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _provider = value;
                      _accountVerified = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _accountController,
                onChanged: (_) => setState(() => _accountVerified = false),
                decoration: const InputDecoration(
                  labelText: 'Mã tài khoản ETC / số điện thoại',
                  hintText: 'Ví dụ: 0912345678',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _plateController,
                onChanged: (_) => setState(() => _accountVerified = false),
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Biển số xe',
                  hintText: 'Ví dụ: 30A-123.45',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Số tiền nạp',
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() => _amount = _parsedAmount);
                },
                decoration: const InputDecoration(
                  labelText: 'Nhập số tiền',
                  suffixText: 'đ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts.map((amount) {
                    return ChoiceChip(
                      label: Text('${formatter.format(amount)}đ'),
                      selected: _amount == amount,
                      onSelected: (_) => _setAmount(amount),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Nguồn tiền',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade50,
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.purple,
              ),
            ),
            title: const Text(
              'Ví AnPay',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Số dư demo: 5.000.000đ'),
            trailing: const Icon(Icons.check_circle, color: Colors.purple),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _lookupLoading ? null : _verifyAccountAndContinue,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: _lookupLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('KIỂM TRA & TIẾP TỤC'),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final money = NumberFormat('#,###');
    return ListView(
      key: const ValueKey('confirm'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _accountVerified
                      ? 'Đã xác minh tài khoản ETC demo: $_verifiedName'
                      : 'Thông tin tài khoản đã sẵn sàng.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Chi tiết giao dịch',
          child: Column(
            children: [
              _ConfirmRow(label: 'Nhà cung cấp', value: _provider),
              _ConfirmRow(
                label: 'Tài khoản ETC',
                value: _accountController.text.trim(),
              ),
              _ConfirmRow(
                label: 'Chủ tài khoản',
                value: _verifiedName ?? 'NGUYEN VAN AN',
              ),
              _ConfirmRow(
                label: 'Biển số xe',
                value: _plateController.text.trim().toUpperCase(),
              ),
              _ConfirmRow(
                label: 'Số tiền nạp',
                value: '${money.format(_amount)}đ',
              ),
              const _ConfirmRow(label: 'Phí dịch vụ', value: '0đ'),
              const Divider(height: 24),
              _ConfirmRow(
                label: 'Tổng thanh toán',
                value: '${money.format(_amount)}đ',
                emphasize: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Thanh toán bằng',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade50,
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.purple,
              ),
            ),
            title: const Text(
              'Ví AnPay',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Số dư demo: 5.000.000đ'),
            trailing: const Icon(Icons.check_circle, color: Colors.purple),
          ),
        ),
        const SizedBox(height: 14),
        const _DemoBanner(
          text:
              'Bước tiếp theo sẽ gửi OTP demo. Không có tiền thật bị trừ và không có yêu cầu nào được gửi đến VETC/ePass.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('CHỈNH SỬA'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _goToOtp,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('XÁC NHẬN ${money.format(_amount)}đ'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return ListView(
      key: const ValueKey('otp'),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 18),
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.purple.shade50,
          child: const Icon(Icons.sms_outlined, color: Colors.purple, size: 38),
        ),
        const SizedBox(height: 18),
        const Text(
          'Xác thực giao dịch',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập mã OTP 6 số để xác nhận nạp tiền cho ${_plateController.text.trim().toUpperCase()}.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'OTP demo: 123456',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 10,
          ),
          decoration: const InputDecoration(
            counterText: '',
            hintText: '------',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _otpController.text = '123456';
            _showMessage('Đã điền OTP demo 123456.');
          },
          child: const Text('ĐIỀN OTP DEMO'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _verifyOtp,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('XÁC THỰC & THANH TOÁN'),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStep() {
    return Center(
      key: const ValueKey('processing'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 58,
              height: 58,
              child: CircularProgressIndicator(strokeWidth: 5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang xử lý giao dịch...',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _processing
                  ? 'AnPay đang mô phỏng bước gửi yêu cầu nạp tiền đến nhà cung cấp ETC.'
                  : 'Hoàn tất xử lý.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 18),
            const Text(
              'Vui lòng không đóng ứng dụng',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    final tx = _completedTransaction!;
    final money = NumberFormat('#,###');
    final time = DateFormat('dd/MM/yyyy • HH:mm:ss').format(tx.createdAt);

    return ListView(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 42,
          backgroundColor: Colors.green.shade50,
          child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nạp tiền thành công',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${money.format(tx.amount)}đ',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'GIAO DỊCH DEMO',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 22),
        _SectionCard(
          title: 'Biên lai giao dịch',
          child: Column(
            children: [
              _ConfirmRow(label: 'Mã giao dịch', value: tx.transactionId),
              _ConfirmRow(label: 'Thời gian', value: time),
              _ConfirmRow(label: 'Dịch vụ', value: 'Nạp tiền ETC'),
              _ConfirmRow(label: 'Nhà cung cấp', value: tx.provider),
              _ConfirmRow(label: 'Tài khoản', value: tx.accountCode),
              _ConfirmRow(label: 'Biển số', value: tx.vehiclePlate),
              _ConfirmRow(label: 'Nguồn tiền', value: 'Ví AnPay (Demo)'),
              const _ConfirmRow(label: 'Phí', value: '0đ'),
              const Divider(height: 24),
              _ConfirmRow(
                label: 'Tổng tiền',
                value: '${money.format(tx.amount)}đ',
                emphasize: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _DemoBanner(
          text:
              'Biên lai này chỉ để trình diễn luồng nghiệp vụ. Không có giao dịch thật tại VETC/ePass hoặc ví AnPay.',
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, tx),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('HOÀN TẤT'),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.purple.shade50,
                child: Icon(icon, color: Colors.purple, size: 27),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.25,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UtilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UtilityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade50,
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle, style: const TextStyle(fontSize: 12.5)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _EtcAccountManagerSheet extends StatefulWidget {
  final String? initialProvider;
  final String? initialAccountCode;
  final String? initialVehiclePlate;

  const _EtcAccountManagerSheet({
    this.initialProvider,
    this.initialAccountCode,
    this.initialVehiclePlate,
  });

  @override
  State<_EtcAccountManagerSheet> createState() =>
      _EtcAccountManagerSheetState();
}

class _EtcAccountManagerSheetState extends State<_EtcAccountManagerSheet> {
  late String _provider;
  late final TextEditingController _accountController;
  late final TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    _provider = widget.initialProvider ?? 'VETC';
    _accountController = TextEditingController(text: widget.initialAccountCode);
    _plateController = TextEditingController(text: widget.initialVehiclePlate);
  }

  @override
  void dispose() {
    _accountController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _save() {
    final account = _accountController.text.trim();
    final plate = _plateController.text.trim().toUpperCase();

    if (account.isEmpty || plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ tài khoản và biển số.')),
      );
      return;
    }

    Navigator.pop(
      context,
      _EtcAccountResult(
        provider: _provider,
        accountCode: account,
        vehiclePlate: plate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý tài khoản ETC',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Liên kết thông tin ETC để sử dụng nhanh ở các lần sau.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Nhà cung cấp',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.toll_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'VETC', child: Text('VETC')),
                DropdownMenuItem(value: 'ePass', child: Text('ePass')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _provider = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Mã tài khoản ETC / số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Biển số xe',
                hintText: 'Ví dụ: 30A-123.45',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const _DemoBanner(
              text:
                  'Demo: thao tác liên kết chỉ lưu trong bộ nhớ khi ứng dụng đang chạy.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.initialAccountCode == null
                      ? 'LIÊN KẾT'
                      : 'LƯU THAY ĐỔI',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  final String text;

  const _DemoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDemoState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyDemoState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 46, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.purple.shade50,
        child: Icon(icon, color: Colors.purple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title đang ở chế độ demo.')));
      },
    );
  }
}

class _EtcAccountResult {
  final String provider;
  final String accountCode;
  final String vehiclePlate;

  const _EtcAccountResult({
    required this.provider,
    required this.accountCode,
    required this.vehiclePlate,
  });
}

class _EtcDemoTransaction {
  final String provider;
  final String accountCode;
  final String vehiclePlate;
  final int amount;
  final String transactionId;
  final DateTime createdAt;

  const _EtcDemoTransaction({
    required this.provider,
    required this.accountCode,
    required this.vehiclePlate,
    required this.amount,
    required this.transactionId,
    required this.createdAt,
  });
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _ConfirmRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
                color: emphasize ? Colors.purple : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
