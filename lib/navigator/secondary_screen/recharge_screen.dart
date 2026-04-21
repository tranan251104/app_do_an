import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/payOS/payos_webview.dart';
import 'package:app_do_an/navigator/payOS/payos_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/model/transaction.dart' as AppModel;
import 'package:app_do_an/navigator/service/transaction_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';

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

  // Dùng URL mặc định của PayOS để đảm bảo Signature luôn khớp
  final String _returnUrl = "https://payos.vn/success"; 

  String? _paymentMethod;

  final List<String> _banks = [
    "MB Bank",
    "Vietcombank",
    "Techcombank",
    "VPBank",
    "BIDV",
    "Agribank",
    "Thanh toán VietQR (PayOS)"
  ];

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
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _walletBalance = prefs.getInt("wallet_balance") ?? 0;
    });
  }

  Future<void> _saveBalance(int newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("wallet_balance", newBalance);
  }

  Future<void> _updateFirestoreBalance(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = fs.FirebaseFirestore.instance.collection('users').doc(user.uid);

    await fs.FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final currentBalance = (snapshot.data()?['balance'] ?? 0) as int;
      tx.update(docRef, {'balance': currentBalance + amount});
    });

    await docRef.collection('transactions').add({
      'title': 'Nạp tiền qua PayOS',
      'amount': amount,
      'createdAt': fs.FieldValue.serverTimestamp(),
    });
  }

  void _setQuickAmount(int value) {
    setState(() {
      _amount = value;
      _controller.text = value.toString();
    });
  }

  void _choosePaymentMethod() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: _banks.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.green),
              title: Text(_banks[index]),
              onTap: () {
                setState(() {
                  _paymentMethod = _banks[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleRecharge() async {
    if (_amount < 10000 || _paymentMethod == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Khi gọi PayOS, dùng description đơn giản (chỉ chữ cái) để tránh lỗi Signature
      final String? paymentUrl = await PayOSService.createPaymentLink(
        amount: _amount,
        description: "NAPTIEN", 
        returnUrl: _returnUrl,
      );

      if (paymentUrl != null) {
        if (!mounted) return;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PayOSWebView(
              paymentUrl: paymentUrl,
              returnUrl: _returnUrl,
              amount: _amount,
            ),
          ),
        );

        if (result is int && result > 0) {
          await _updateFirestoreBalance(result);
          final newBalance = _walletBalance + result;
          await _saveBalance(newBalance);

          final now = DateFormat("HH:mm dd/MM").format(DateTime.now());
          await TransactionStorage.addTransaction(
            AppModel.Transaction(
              title: "Nạp tiền qua PayOS",
              amount: result,
              time: now,
            ),
          );

          if (!mounted) return;
          setState(() => _walletBalance = newBalance);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nạp $result đ thành công")));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nạp tiền"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nhập số tiền (tối thiểu 10.000đ)"),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => _amount = int.tryParse(val) ?? 0),
              decoration: InputDecoration(
                prefixText: "đ ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            Text("Số dư hiện tại: đ$_walletBalance", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickButton(100000),
                _quickButton(200000),
                _quickButton(500000),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.green),
              title: Text(_paymentMethod ?? "Chọn phương thức thanh toán"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _choosePaymentMethod,
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_amount >= 10000 && _paymentMethod != null && !_isLoading) ? _handleRecharge : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Nạp tiền ngay", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(int value) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(value),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: _amount == value ? Colors.green : Colors.grey),
        backgroundColor: _amount == value ? Colors.green.shade50 : null,
      ),
      child: Text("${value ~/ 1000}.000"),
    );
  }
}
