import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/fourth_screen/otp_confirm_screen.dart';
import 'package:app_do_an/navigator/model/bank_catalog.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransferMoneyFormScreen extends StatefulWidget {
  final PaymentAccount account;
  final int? presetAmount;

  const TransferMoneyFormScreen({
    super.key,
    required this.account,
    this.presetAmount,
  });

  @override
  State<TransferMoneyFormScreen> createState() => _TransferMoneyFormScreenState();
}

class _TransferMoneyFormScreenState extends State<TransferMoneyFormScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _walletBalance = 0;
  bool _isLoading = false;

  bool get _isInternalAnPay =>
      widget.account.accountNumber.toUpperCase().startsWith('ANP') ||
      widget.account.provider.toUpperCase().contains('ANPAY');

  bool get _isExternalBank => !_isInternalAnPay && !widget.account.isService;

  BankOption? get _bank =>
      bankByBin(widget.account.bankBin) ?? bankByName(widget.account.provider);

  String? get _bankBin => widget.account.bankBin ?? _bank?.bin;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    if (widget.presetAmount != null) {
      _amountController.text = widget.presetAmount.toString();
    }
    _amountController.addListener(_redraw);
  }

  @override
  void dispose() {
    _amountController.removeListener(_redraw);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  Future<void> _loadBalance() async {
    AppLogger.repo('TRANSFER_UI', 'Loading wallet balance for transfer form');
    try {
      final wallet = await AppServices.wallet.me();
      if (!mounted) return;
      setState(() {
        _walletBalance = (wallet['availableBalance'] as num?)?.toInt() ?? 0;
      });
      AppLogger.success(
        'TRANSFER_UI',
        'Wallet balance loaded',
        {'availableBalance': _walletBalance},
      );
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'TRANSFER_UI',
        'Wallet balance load failed',
        error: e,
        stackTrace: stackTrace,
      );
      _show(e.message);
    }
  }

  int _parseAmount() {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _prepareTransfer() async {
    final amount = _parseAmount();
    AppLogger.action(
      _isExternalBank
          ? 'EXTERNAL_TRANSFER: CONTINUE button pressed'
          : 'TRANSFER: CONTINUE button pressed',
      {
        'recipient': AppLogger.mask(widget.account.accountNumber),
        'provider': widget.account.provider,
        'amount': amount,
      },
    );

    if (widget.account.isService) {
      AppLogger.warning(
        'TRANSFER_UI',
        'Transfer blocked: service payment is not supported here',
        {'provider': widget.account.provider},
      );
      _show('Thanh toán dịch vụ chưa được hỗ trợ ở màn chuyển tiền này.');
      return;
    }

    if (amount < 10000) {
      AppLogger.warning(
        'TRANSFER_UI',
        'Transfer blocked: amount below minimum',
        {'amount': amount},
      );
      _show('Số tiền tối thiểu là 10.000₫');
      return;
    }

    if (amount > _walletBalance) {
      AppLogger.warning(
        'TRANSFER_UI',
        'Transfer blocked: insufficient balance',
        {'amount': amount, 'availableBalance': _walletBalance},
      );
      _show('Số dư không đủ');
      return;
    }

    if (_isExternalBank && (_bankBin == null || _bankBin!.isEmpty)) {
      AppLogger.warning(
        'EXTERNAL_TRANSFER_UI',
        'Transfer blocked: bank BIN missing',
        {'bank': widget.account.provider},
      );
      _show('Ngân hàng này chưa có mã BIN để mô phỏng chuyển tiền.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final me = await AppServices.user.me();
      final email = me['email']?.toString() ?? '';
      if (email.isEmpty) {
        throw const ApiException(
          code: 'EMAIL_OTP_REQUIRED',
          message:
              'Tài khoản chỉ có số điện thoại chưa thể nhận OTP chuyển tiền. Backend hiện gửi OTP qua email.',
        );
      }

      if (_isExternalBank) {
        await _prepareExternal(amount);
      } else {
        await _prepareInternal(amount);
      }
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        _isExternalBank ? 'EXTERNAL_TRANSFER_UI' : 'TRANSFER_UI',
        'Prepare transfer failed',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'status': e.statusCode},
      );
      _show(e.message);
    } catch (e, stackTrace) {
      AppLogger.error(
        _isExternalBank ? 'EXTERNAL_TRANSFER_UI' : 'TRANSFER_UI',
        'Prepare transfer failed unexpectedly',
        error: e,
        stackTrace: stackTrace,
      );
      _show('Không thể chuẩn bị giao dịch: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _prepareInternal(int amount) async {
    AppLogger.repo(
      'TRANSFER_UI',
      'Preparing internal AnPay transfer',
      {
        'amount': amount,
        'recipient': AppLogger.mask(widget.account.accountNumber),
      },
    );

    final prepared = await AppServices.transfer.prepare(
      walletCode: widget.account.accountNumber,
      amount: amount,
      note: _noteController.text,
    );

    AppLogger.success(
      'TRANSFER_UI',
      'Internal transfer prepared; opening OTP screen',
      {
        'transactionId':
            AppLogger.mask(prepared['transactionId']?.toString()),
      },
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpConfirmScreen(
          transferId: prepared['transactionId'].toString(),
          reference: prepared['reference']?.toString() ?? '',
          receiverName:
              prepared['receiverDisplayName']?.toString() ?? widget.account.name,
          receiverWalletCode:
              prepared['receiverWalletCode']?.toString() ??
                  widget.account.accountNumber,
          amount: (prepared['amount'] as num?)?.toInt() ?? amount,
          expiresAt:
              DateTime.tryParse(prepared['expiresAt']?.toString() ?? ''),
        ),
      ),
    );
    await _loadBalance();
  }

  Future<void> _prepareExternal(int amount) async {
    AppLogger.repo(
      'EXTERNAL_TRANSFER_UI',
      'Preparing simulated bank transfer',
      {
        'amount': amount,
        'bank': widget.account.provider,
        'bankBin': _bankBin,
        'account': AppLogger.mask(widget.account.accountNumber),
      },
    );

    final prepared = await AppServices.transfer.prepareExternal(
      bankBin: _bankBin!,
      bankName: widget.account.provider,
      accountNumber: widget.account.accountNumber,
      accountName: widget.account.name,
      amount: amount,
      note: _noteController.text,
    );

    AppLogger.success(
      'EXTERNAL_TRANSFER_UI',
      'Simulated bank transfer prepared; opening OTP screen',
      {
        'transactionId':
            AppLogger.mask(prepared['transactionId']?.toString()),
        'bank': prepared['bankName']?.toString(),
        'status': prepared['status']?.toString(),
      },
    );

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpConfirmScreen(
          transferId: prepared['transactionId'].toString(),
          reference: prepared['reference']?.toString() ?? '',
          receiverName:
              prepared['accountName']?.toString() ?? widget.account.name,
          receiverWalletCode:
              prepared['accountNumberMasked']?.toString() ??
                  _maskAccount(widget.account.accountNumber),
          amount: (prepared['amount'] as num?)?.toInt() ?? amount,
          expiresAt:
              DateTime.tryParse(prepared['expiresAt']?.toString() ?? ''),
          external: true,
          bankName:
              prepared['bankName']?.toString() ?? widget.account.provider,
        ),
      ),
    );
    await _loadBalance();
  }

  String _maskAccount(String value) {
    if (value.length <= 4) return '****';
    return '****${value.substring(value.length - 4)}';
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _amountController.text.isNotEmpty && !_isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.account.isService
              ? 'Thanh toán'
              : _isExternalBank
                  ? 'Chuyển đến ngân hàng'
                  : 'Chuyển tiền',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _recipientLogo(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.account.name.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _isExternalBank
                                  ? '${widget.account.provider} · ${_maskAccount(widget.account.accountNumber)}'
                                  : '${widget.account.provider} · ${widget.account.accountNumber}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (_isExternalBank && _bankBin != null)
                              Text(
                                'BIN $_bankBin',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 12,
                                ),
                              ),
                            if (widget.account.detail != null)
                              Text(
                                widget.account.detail!,
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isExternalBank)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.amber.shade50,
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Giao dịch mô phỏng: sau khi OTP đúng, Backend sẽ trừ số dư ví AnPay và ghi sổ giao dịch. Tài khoản ngân hàng ngoài không nhận tiền thật.',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số tiền',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          suffixText: '₫',
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(),
                      Text(
                        'Số dư khả dụng: ${NumberFormat.decimalPattern('vi').format(_walletBalance)} ₫',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Nội dung chuyển tiền (không bắt buộc)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: isFormValid ? _prepareTransfer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isExternalBank
                                ? 'TIẾP TỤC MÔ PHỎNG'
                                : 'TIẾP TỤC',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isExternalBank
                      ? 'OTP được backend xác minh trước khi trừ số dư mô phỏng.'
                      : 'OTP được backend tạo và xác minh cùng giao dịch chuyển tiền.',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _recipientLogo() {
    if (_isExternalBank && (_bank?.logoUrl.isNotEmpty ?? false)) {
      return Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.network(
          _bank!.logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.account_balance,
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.deepPurpleAccent.shade100,
      child: Text(
        widget.account.name.isEmpty
            ? 'A'
            : widget.account.name[0].toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
