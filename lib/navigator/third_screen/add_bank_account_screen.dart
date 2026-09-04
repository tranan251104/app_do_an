import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/model/bank_catalog.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:flutter/material.dart';

class BankAccountFormResult {
  final PaymentAccount account;
  final bool saveAccount;

  const BankAccountFormResult({
    required this.account,
    required this.saveAccount,
  });
}

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  BankOption? _selectedBank;
  final _accountController = TextEditingController();
  final _ownerController = TextEditingController();
  bool _saveAccount = true;

  bool get isFormValid {
    final account = _accountController.text.trim();
    return _selectedBank != null &&
        RegExp(r'^\d{6,20}$').hasMatch(account) &&
        _ownerController.text.trim().length >= 2;
  }

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_redraw);
    _ownerController.addListener(_redraw);
  }

  @override
  void dispose() {
    _accountController.removeListener(_redraw);
    _ownerController.removeListener(_redraw);
    _accountController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  Future<void> _chooseBank() async {
    AppLogger.action('EXTERNAL_TRANSFER choose bank pressed');
    final searchController = TextEditingController();
    String query = '';

    final result = await showModalBottomSheet<BankOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = bankCatalog.where((b) => b.matches(query)).toList();
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chọn ngân hàng nhận',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Tìm MB, Vietcombank, BIDV...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setSheetState(() => query = value),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Không tìm thấy ngân hàng'))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final bank = filtered[index];
                              return ListTile(
                                leading: _BankLogo(bank: bank, size: 44),
                                title: Text(
                                  bank.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text('${bank.code} · BIN ${bank.bin}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pop(sheetContext, bank),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    searchController.dispose();

    if (result != null) {
      AppLogger.action(
        'EXTERNAL_TRANSFER bank selected',
        {'bank': result.name, 'bankBin': result.bin},
      );
      setState(() => _selectedBank = result);
    }
  }

  void _submit() {
    AppLogger.action(
      'EXTERNAL_TRANSFER recipient continue pressed',
      {
        'bank': _selectedBank?.name,
        'account': AppLogger.mask(_accountController.text.trim()),
        'saveBeneficiary': _saveAccount,
      },
    );

    if (!isFormValid) return;

    final bank = _selectedBank!;
    final account = PaymentAccount.fromBank(
      bankName: bank.name,
      bankBin: bank.bin,
      bankCode: bank.code,
      logoUrl: bank.logoUrl,
      accountNumber: _accountController.text.trim(),
      ownerName: _ownerController.text.trim().toUpperCase(),
    );

    Navigator.pop(
      context,
      BankAccountFormResult(account: account, saveAccount: _saveAccount),
    );
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
                    'Chế độ mô phỏng: Backend AnPay sẽ trừ số dư trong ví demo và ghi giao dịch, nhưng không có tiền thật được chuyển vào ngân hàng bên ngoài.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 12),
              children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: _selectedBank == null
                        ? const CircleAvatar(child: Icon(Icons.account_balance))
                        : _BankLogo(bank: _selectedBank!, size: 46),
                    title: const Text('Ngân hàng nhận'),
                    subtitle: Text(
                      _selectedBank?.name ?? 'Chọn ngân hàng',
                      style: TextStyle(
                        color: _selectedBank == null ? Colors.grey : Colors.black,
                        fontWeight: _selectedBank == null ? FontWeight.normal : FontWeight.w700,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _chooseBank,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      labelText: 'Số tài khoản',
                      hintText: 'Nhập 6 - 20 chữ số',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Divider(height: 1),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _ownerController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Tên người nhận (giả lập)',
                      hintText: 'NGUYEN VAN A',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.white,
                  child: SwitchListTile(
                    value: _saveAccount,
                    onChanged: (value) => setState(() => _saveAccount = value),
                    title: const Text('Lưu người thụ hưởng'),
                    subtitle: const Text('Lưu tài khoản này để chuyển nhanh lần sau'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isFormValid ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'TIẾP TỤC CHUYỂN TIỀN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankLogo extends StatelessWidget {
  final BankOption bank;
  final double size;

  const _BankLogo({required this.bank, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
