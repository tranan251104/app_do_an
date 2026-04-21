import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_do_an/navigator/model/bankAccount1.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/model/transaction.dart' as model;
import 'package:app_do_an/navigator/service/transaction_storage.dart';
import 'package:app_do_an/navigator/fourth_screen/otp_confirm_screen.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:app_do_an/navigator/fourth_screen/otp_confirm_phone_screen.dart';

class TransferMoneyFormScreen extends StatefulWidget {
  final BankAccount1? account1;
  final BankAccount2? account2;
  final int? presetAmount;

  const TransferMoneyFormScreen({
    super.key,
    this.account1,
    this.account2,
    this.presetAmount,
  });

  @override
  State<TransferMoneyFormScreen> createState() => _TransferMoneyFormScreenState();
}

class _TransferMoneyFormScreenState extends State<TransferMoneyFormScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _walletBalance = 0;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
    if (widget.presetAmount != null) {
      _amountController.text = NumberFormat.decimalPattern().format(widget.presetAmount);
    }
    _amountController.addListener(() => setState(() {}));
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _walletBalance = prefs.getInt("wallet_balance") ?? 0);
  }

  Future<void> _completeTransaction(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final nowFormatted = DateFormat("HH:mm dd/MM/yyyy").format(DateTime.now());
    String title = widget.account1 != null 
        ? "Chuyển tiền cho ${widget.account1!.ownerName}"
        : "Thanh toán ${widget.account2!.serviceName}";

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDoc);
      int currentBalance = (snapshot.data() as Map<String, dynamic>)['balance'] ?? 0;
      transaction.update(userDoc, {'balance': currentBalance - amount});
    });

    await userDoc.collection('transactions').add({
      'title': title,
      'amount': -amount,
      'createdAt': FieldValue.serverTimestamp(),
      'displayTime': nowFormatted,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("wallet_balance", (prefs.getInt("wallet_balance") ?? 0) - amount);
    await TransactionStorage.addTransaction(model.Transaction(title: title, amount: -amount, time: nowFormatted));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionResultScreen(
          bankName: widget.account1?.bankName ?? "",
          accountName: widget.account1?.ownerName ?? "${widget.account2!.serviceName}",
          amount: amount,
          time: nowFormatted,
          isServiceTransaction: widget.account2 != null,
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    if (widget.account1 != null) {
      final account = widget.account1!;
      return Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurpleAccent,
            child: Text(account.ownerName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(account.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${account.bankName} *${account.accountNumber.substring(account.accountNumber.length - 4)}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      );
    } else {
      final service = widget.account2!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("Nhà cung cấp: ${service.provider}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text("Chi tiết: ${service.detail}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _amountController.text.isNotEmpty && _errorMessage == null && !_isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Chuyển đến"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(color: Colors.white, padding: const EdgeInsets.all(16), child: _buildAccountInfo()),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Số tiền", style: TextStyle(color: Colors.black54)),
                      TextField(
                        controller: _amountController,
                        enabled: widget.presetAmount == null,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(hintText: "₫", border: InputBorder.none),
                      ),
                      Text("Số dư Ví: ₫${NumberFormat.decimalPattern().format(_walletBalance)}", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: "Mô tả giao dịch", border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: isFormValid ? () async {
                      final cleanVal = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      final amount = int.tryParse(cleanVal) ?? 0;
                      final prefs = await SharedPreferences.getInstance();
                      final userEmail = prefs.getString('user_email');
                      final userPhone = prefs.getString('phone');

                      setState(() => _isLoading = true);
                      try {
                        if (userEmail != null && userEmail.isNotEmpty) {
                          await OtpService.sendOtp(userEmail);
                          if (!mounted) return;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => OtpConfirmScreen(email: userEmail, account1: widget.account1, account2: widget.account2, amount: amount)));
                        } else if (userPhone != null && userPhone.isNotEmpty) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => OtpPhoneConfirmScreen(phone: userPhone, onVerified: () => _completeTransaction(amount))));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, minimumSize: const Size(double.infinity, 50)),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          if (_isLoading) Container(color: Colors.black.withOpacity(0.1), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
