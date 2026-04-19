import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount1.dart';

class AddBankAccountScreen extends StatefulWidget {
  final Function(BankAccount1) onSubmit;

  const AddBankAccountScreen({super.key, required this.onSubmit});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  String? _selectedBank;
  final _accountController = TextEditingController();
  final _ownerController = TextEditingController();
  bool _saveAccount = true;

  final List<String> banks = [
    "MB Bank",
    "Vietcombank",
    "Techcombank",
    "BIDV",
    "Agribank",
    "VPBank",
  ];

  @override
  void initState() {
    super.initState();
    _accountController.addListener(() => setState(() {}));
    _ownerController.addListener(() => setState(() {}));
  }

  bool get isFormValid {
    return _selectedBank != null &&
        _accountController.text.isNotEmpty &&
        _ownerController.text.isNotEmpty;
  }

  void _chooseBank() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView(
          children: banks
              .map((bank) => ListTile(
                    title: Text(bank),
                    onTap: () => Navigator.pop(context, bank),
                  ))
              .toList(),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedBank = result;
      });
    }
  }

  void _submit() {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final account = BankAccount1(
      bankName: _selectedBank!,
      accountNumber: _accountController.text,
      ownerName: _ownerController.text,
    );

    if (_saveAccount) {
      widget.onSubmit(account);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chuyển đến Ngân hàng bất kỳ"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.all(12),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber, color: Colors.deepPurpleAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Vui lòng kiểm tra kỹ Tên Ngân hàng, Số tài khoản và "
                    "Tên chủ tài khoản trước khi tiếp tục.",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: const Text("Tên ngân hàng"),
                  trailing: Text(
                    _selectedBank ?? "Chọn ngân hàng",
                    style: TextStyle(
                      color:
                          _selectedBank == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  onTap: _chooseBank,
                ),
                const Divider(),

                ListTile(
                  title: TextField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Nhập Số tài khoản",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Divider(),

                ListTile(
                  title: TextField(
                    controller: _ownerController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Điền tên đầy đủ",
                    ),
                  ),
                ),
                const Divider(),

                SwitchListTile(
                  value: _saveAccount,
                  onChanged: (val) => setState(() => _saveAccount = val),
                  title: const Text("Lưu tài khoản"),
                ),
              ],
            ),
          ),

          // 🔹 Nút "TIẾP THEO" bật/tắt tùy theo form
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFormValid ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFormValid ? Colors.deepPurpleAccent : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("TIẾP THEO"),
            ),
          )
        ],
      ),
    );
  }
}

