import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/payment_gateway/anpay_gateway_webview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final TextEditingController _controller = TextEditingController();
  int _amount = 0;
  int _walletBalance = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    AppLogger.repo('TOPUP_UI', 'Loading wallet balance');
    try {
      final wallet = await AppServices.wallet.me();
      if (!mounted) return;
      setState(() {
        _walletBalance = (wallet['availableBalance'] as num?)?.toInt() ?? 0;
      });
      AppLogger.success('TOPUP_UI', 'Wallet balance loaded', {
        'availableBalance': _walletBalance,
      });
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'TOPUP_UI',
        'Loading wallet balance failed',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'status': e.statusCode},
      );
      _show(e.message);
    }
  }

  void _setQuickAmount(int value) {
    AppLogger.action('TOPUP quick amount pressed', {'amount': value});
    setState(() {
      _amount = value;
      _controller.text = value.toString();
    });
  }

  Future<void> _handleRecharge() async {
    AppLogger.action('TOPUP: CONFIRM button pressed', {'amount': _amount});

    if (_amount < 10000 || _isLoading) {
      AppLogger.warning('TOPUP_UI', 'Topup ignored by validation/loading', {
        'amount': _amount,
        'loading': _isLoading,
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      AppLogger.repo('TOPUP_UI', 'Creating ANPAY gateway payment intent', {
        'amount': _amount,
      });

      final intent = await AppServices.payment.createAnPayGatewayTopup(_amount);
      final paymentUrl = intent['checkoutUrl']?.toString() ?? '';
      final paymentIntentId = intent['paymentIntentId']?.toString() ?? '';
      final backendAmount = (intent['amount'] as num?)?.toInt();
      final status = intent['status']?.toString();

      if (paymentUrl.isEmpty || paymentIntentId.isEmpty) {
        throw const ApiException(
          code: 'PAYMENT_LINK_MISSING',
          message: 'Backend không trả về liên kết thanh toán hợp lệ',
        );
      }

      if (backendAmount != null && backendAmount != _amount) {
        AppLogger.warning(
          'TOPUP_UI',
          'Backend amount differs from requested amount',
          {'requestedAmount': _amount, 'backendAmount': backendAmount},
        );
      }

      AppLogger.success(
        'TOPUP_UI',
        'ANPAY payment intent created; opening gateway',
        {
          'paymentIntentId': AppLogger.mask(paymentIntentId),
          'amount': backendAmount ?? _amount,
          'status': status,
          'checkoutHost': Uri.tryParse(paymentUrl)?.host,
        },
      );

      if (!mounted) return;

      // Do not keep the loading overlay over the WebView transition.
      setState(() => _isLoading = false);

      final paid = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AnPayGatewayWebView(
            paymentUrl: paymentUrl,
            paymentIntentId: paymentIntentId,
          ),
        ),
      );

      AppLogger.repo('TOPUP_UI', 'ANPAY gateway closed', {
        'paid': paid,
        'paymentIntentId': AppLogger.mask(paymentIntentId),
      });

      // The backend is the source of truth. Always refresh the wallet after
      // returning from checkout instead of changing the balance in Flutter.
      await _loadBalance();
      if (!mounted) return;

      if (paid == true) {
        AppLogger.success(
          'TOPUP_UI',
          'Topup completed and wallet balance refreshed',
          {
            'paymentIntentId': AppLogger.mask(paymentIntentId),
            'availableBalance': _walletBalance,
          },
        );
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nạp tiền thành công'),
            content: Text(
              'Backend đã xác nhận giao dịch. Số dư hiện tại: ${NumberFormat('#,###').format(_walletBalance)}đ',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ĐÓNG'),
              ),
            ],
          ),
        );
      } else {
        _show(
          'Giao dịch chưa hoàn tất hoặc đã bị hủy. Số dư đã được tải lại từ backend.',
        );
      }
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'TOPUP_UI',
        'Topup failed',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'status': e.statusCode},
      );
      _show(e.message);
    } catch (e, stackTrace) {
      AppLogger.error(
        'TOPUP_UI',
        'Topup failed unexpectedly',
        error: e,
        stackTrace: stackTrace,
      );
      _show('Không thể tạo giao dịch nạp tiền: $e');
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nạp tiền'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nhập số tiền muốn nạp (Tối thiểu 10.000đ)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    _amount = int.tryParse(value.replaceAll(',', '')) ?? 0;
                  }),
                  decoration: InputDecoration(
                    prefixText: 'đ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số dư hiện tại:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'đ${NumberFormat('#,###').format(_walletBalance)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _quickButton(100000),
                    _quickButton(200000),
                    _quickButton(500000),
                  ],
                ),
                const SizedBox(height: 24),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.deepPurple,
                  ),
                  title: Text('ANPAY Payment Gateway'),
                  subtitle: Text(
                    'Thanh toán mô phỏng qua backend • chọn ngân hàng trên trang thanh toán',
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _amount >= 10000 && !_isLoading
                        ? _handleRecharge
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'TIẾP TỤC THANH TOÁN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _quickButton(int value) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(value),
      child: Text('${value ~/ 1000}k'),
    );
  }
}
