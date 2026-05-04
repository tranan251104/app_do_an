import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/fourth_screen/otp_confirm_screen.dart';
import 'package:app_do_an/navigator/service/otp.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBalance();
    if (widget.presetAmount != null) {
      _amountController.text = widget.presetAmount.toString();
    }
    _amountController.addListener(() => setState(() {}));
  }

  Future<void> _loadBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _walletBalance = doc.data()?['balance'] ?? 0;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("wallet_balance", _walletBalance);
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    setState(() => _walletBalance = prefs.getInt("wallet_balance") ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    bool isFormValid = _amountController.text.isNotEmpty && !_isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.isService ? "Thanh toán" : "Chuyển tiền"), 
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
                      CircleAvatar(
                        backgroundColor: Colors.deepPurpleAccent.shade100, 
                        child: Text(widget.account.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${widget.account.provider} - ${widget.account.accountNumber}", style: const TextStyle(color: Colors.grey)),
                            if (widget.account.detail != null)
                              Text(widget.account.detail!, style: const TextStyle(color: Colors.deepPurple, fontSize: 12)),
                          ],
                        ),
                      )
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
                      const Text("Số tiền", style: TextStyle(color: Colors.black54)),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        decoration: const InputDecoration(
                          hintText: "0", 
                          suffixText: "₫",
                          border: InputBorder.none
                        ),
                      ),
                      const Divider(),
                      Text("Số dư khả dụng: ${NumberFormat.decimalPattern().format(_walletBalance)} ₫", 
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                      hintText: "Mô tả giao dịch (không bắt buộc)", 
                      border: InputBorder.none
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: isFormValid ? () async {
                      final amount = int.tryParse(_amountController.text) ?? 0;
                      if (amount < 10000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Số tiền tối thiểu là 10.000₫"))
                        );
                        return;
                      }

                      if (amount > _walletBalance) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Số dư không đủ"))
                        );
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      final userEmail = prefs.getString('user_email');
                      
                      setState(() => _isLoading = true);
                      try {
                        if (userEmail != null && userEmail.isNotEmpty) {
                          await OtpService.sendOtp(userEmail);
                          if (!mounted) return;
                          
                          Navigator.push(context, MaterialPageRoute(builder: (_) => OtpConfirmScreen(
                            email: userEmail, 
                            account: widget.account, 
                            amount: amount
                          )));
                        } else {
                          throw Exception("Không tìm thấy email người dùng");
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent, 
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Xác thực OTP sẽ được thực hiện ở bước sau", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (_isLoading) Container(color: Colors.black.withOpacity(0.1), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
