import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'add_bank_account_screen.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart'; 

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  List<PaymentAccount> savedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList("bankAccounts");
    if (data != null) {
      setState(() {
        savedAccounts =
            data.map((e) => PaymentAccount.fromJson(json.decode(e))).toList();
      });
    }
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = savedAccounts.map((acc) => json.encode(acc.toJson())).toList();
    await prefs.setStringList("bankAccounts", data);
  }

  void _addAccount(PaymentAccount account) {
    setState(() {
      savedAccounts.add(account);
    });
    _saveAccounts();
  }

  void _clearAccounts() {
    setState(() {
      savedAccounts.clear();
    });
    _saveAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chuyển tiền tới Tài khoản Ngân hàng"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Nút thêm tài khoản
          ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.red),
            title: const Text("Thêm Tài khoản Ngân hàng mới"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBankAccountScreen(
                    onSubmit: _addAccount,
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // Header + nút sửa
          if (savedAccounts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tài khoản Ngân hàng đã lưu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _clearAccounts,
                    child: const Text("Sửa"),
                  ),
                ],
              ),
            ),

          // Danh sách hoặc trống
          Expanded(
            child: savedAccounts.isEmpty
                ? const Center(
                    child: Text("Danh sách tài khoản trống",
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: savedAccounts.length,
                    itemBuilder: (context, index) {
                      final acc = savedAccounts[index];
                      return ListTile(
                        leading: const Icon(Icons.account_balance,
                            color: Colors.red),
                        title: Text(acc.name.toUpperCase()),
                        subtitle: Text(
                          "${acc.provider} *${acc.accountNumber.length > 4 ? acc.accountNumber.substring(acc.accountNumber.length - 4) : acc.accountNumber}",
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransferMoneyFormScreen(account: acc),
                            ),
                          );

                          if (result == true) {
                            Navigator.pop(context, true); // trả tiếp về TransferMoneyScreen
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
