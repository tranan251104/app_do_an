import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/bank_catalog.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:flutter/material.dart';

import 'add_bank_account_screen.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  List<Map<String, dynamic>> _saved = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    AppLogger.repo('BENEFICIARY_UI', 'Load saved bank accounts');
    try {
      final data = await AppServices.beneficiary.list();
      if (mounted) {
        setState(() => _saved = data.where((e) => e['type'] == 'BANK').toList());
      }
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'BENEFICIARY_UI',
        'Load bank beneficiaries failed',
        error: e,
        stackTrace: stackTrace,
      );
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openNewRecipient() async {
    AppLogger.action('EXTERNAL_TRANSFER new recipient pressed');
    final result = await Navigator.push<BankAccountFormResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddBankAccountScreen()),
    );

    if (!mounted || result == null) return;

    if (result.saveAccount) {
      await _saveAccount(result.account);
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(account: result.account),
      ),
    );
    await _loadAccounts();
  }

  Future<void> _saveAccount(PaymentAccount account) async {
    AppLogger.action(
      'BENEFICIARY add bank account',
      {
        'bank': account.provider,
        'bankBin': account.bankBin,
        'account': AppLogger.mask(account.accountNumber),
      },
    );
    try {
      await AppServices.beneficiary.create({
        'type': 'BANK',
        'bankName': account.provider,
        'bankBin': account.bankBin,
        'accountNumber': account.accountNumber,
        'accountName': account.name,
        'nickname': account.name,
      });
      await _loadAccounts();
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'BENEFICIARY_UI',
        'Save bank beneficiary failed',
        error: e,
        stackTrace: stackTrace,
      );
      _show(e.message);
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    AppLogger.action(
      'BENEFICIARY delete pressed',
      {'id': AppLogger.mask(item['id']?.toString())},
    );
    final id = item['id']?.toString();
    if (id == null) return;
    try {
      await AppServices.beneficiary.delete(id);
      await _loadAccounts();
    } on ApiException catch (e) {
      _show(e.message);
    }
  }

  PaymentAccount _accountFromSaved(Map<String, dynamic> item) {
    final bankBin = item['bankBin']?.toString();
    final bankName = item['bankName']?.toString() ?? 'Ngân hàng';
    final bank = bankByBin(bankBin) ?? bankByName(bankName);
    return PaymentAccount.fromBank(
      bankName: bank?.name ?? bankName,
      bankBin: bankBin ?? bank?.bin,
      bankCode: bank?.code,
      logoUrl: bank?.logoUrl,
      accountNumber: item['accountNumber']?.toString() ?? '',
      ownerName: item['accountName']?.toString() ??
          item['nickname']?.toString() ??
          'Người nhận',
    );
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển đến ngân hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade50,
            padding: const EdgeInsets.all(12),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science_outlined, color: Colors.deepPurple),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mô phỏng liên ngân hàng: tiền sẽ bị trừ khỏi ví AnPay trong database, nhưng không đi tới tài khoản ngân hàng thật.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1ECFF),
                child: Icon(Icons.add, color: Colors.deepPurple),
              ),
              title: const Text(
                'Chuyển tới tài khoản mới',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Chọn ngân hàng, nhập số tài khoản và tên người nhận'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openNewRecipient,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Người thụ hưởng đã lưu',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _saved.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có tài khoản đã lưu',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _saved.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _saved[index];
                          final account = _accountFromSaved(item);
                          final bank = bankByBin(account.bankBin) ??
                              bankByName(account.provider);
                          return Container(
                            color: Colors.white,
                            child: ListTile(
                              leading: bank == null
                                  ? const CircleAvatar(
                                      child: Icon(Icons.account_balance),
                                    )
                                  : _BankLogo(bank: bank),
                              title: Text(
                                account.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(
                                '${account.provider} · ${_maskAccount(account.accountNumber)}',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') _delete(item);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Xóa người thụ hưởng'),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransferMoneyFormScreen(account: account),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _maskAccount(String value) {
    if (value.length <= 4) return '****';
    return '****${value.substring(value.length - 4)}';
  }
}

class _BankLogo extends StatelessWidget {
  final BankOption bank;

  const _BankLogo({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Image.network(
        bank.logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            bank.code,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
