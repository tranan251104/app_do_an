import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/third_screen/bank_account_screen.dart';
import 'package:flutter/material.dart';

class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({super.key});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openAnPayTransfer() async {
    AppLogger.action('TRANSFER: open AnPay transfer flow');

    final walletCode = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _AnPayWalletDialog(),
    );

    if (!mounted || walletCode == null) {
      AppLogger.warning('TRANSFER_UI', 'AnPay transfer dialog cancelled');
      return;
    }

    // Let AlertDialog/TextField finish deactivation before pushing a new route.
    // Pushing immediately while the dialog's inherited dependencies are still
    // being removed can trigger "_dependents.isEmpty" / wrong build scope.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    AppLogger.action(
      'TRANSFER: recipient entered',
      {'walletCode': AppLogger.mask(walletCode)},
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(
          account: PaymentAccount(
            accountNumber: walletCode,
            name: 'Người nhận AnPay',
            provider: 'ANPAY Internal',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển tiền'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  Icons.account_balance_wallet,
                  'Ví AnPay',
                  _openAnPayTransfer,
                ),
                _actionButton(
                  Icons.qr_code_scanner,
                  'Quét QR',
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dùng tab QR để quét mã AnPay.')),
                  ),
                ),
                _actionButton(
                  Icons.account_balance,
                  'Rút tiền',
                  () => _unsupported('Rút tiền'),
                ),
                _actionButton(
                  Icons.card_giftcard,
                  'Gửi Lì Xì',
                  () => _unsupported('Gửi Lì Xì'),
                ),
                _actionButton(
                  Icons.account_balance_outlined,
                  'Đến Ngân hàng',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BankAccountScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.purple,
              tabs: const [
                Tab(text: 'Người nhận gần đây'),
                Tab(text: 'Mục yêu thích'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _emptyState(
                  'Không tìm thấy người nhận gần đây',
                  'Nhập mã ví AnPay hoặc quét QR để bắt đầu.',
                ),
                _emptyState(
                  'Chưa có mục yêu thích',
                  'Danh sách người thụ hưởng ngân hàng nằm trong mục Đến Ngân hàng.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _unsupported(String feature) {
    AppLogger.action('Unsupported transfer feature pressed', {'feature': feature});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature chưa có API nghiệp vụ hoàn chỉnh trên backend nên đang được khóa để tránh thay đổi số dư phía client.',
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppLogger.action('TRANSFER menu pressed', {'label': label});
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.red.shade50,
            child: Icon(icon, size: 28, color: Colors.purple),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnPayWalletDialog extends StatefulWidget {
  const _AnPayWalletDialog();

  @override
  State<_AnPayWalletDialog> createState() => _AnPayWalletDialogState();
}

class _AnPayWalletDialogState extends State<_AnPayWalletDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim().toUpperCase();
    if (value.isEmpty) return;

    // Remove focus first so the editable text/keyboard can cleanly detach
    // before the dialog route is popped.
    _focusNode.unfocus();
    Navigator.of(context).pop(value);
  }

  void _cancel() {
    _focusNode.unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chuyển tới ví AnPay'),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Mã ví ANP...',
          hintText: 'Ví dụ: ANP123456789',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('HỦY'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('TIẾP TỤC'),
        ),
      ],
    );
  }
}
