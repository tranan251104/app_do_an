import 'package:flutter/material.dart';
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

  String? _paymentMethod;

  final List<String> _banks = [
    "MB Bank (Demo)",
    "Vietcombank (Demo)",
    "Techcombank (Demo)",
    "Ví điện tử (Demo)",
    "Nạp tiền nhanh (Giả lập)"
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
      'title': 'Nạp tiền (Giả lập)',
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
              leading: const Icon(Icons.account_balance, color: Colors.deepPurple),
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
      // GIẢ LẬP: Chờ 2 giây để mô phỏng quá trình xử lý nạp tiền
      await Future.delayed(const Duration(seconds: 2));

      // Cập nhật số dư Firestore
      await _updateFirestoreBalance(_amount);
      
      // Cập nhật số dư Local
      final newBalance = _walletBalance + _amount;
      await _saveBalance(newBalance);

      // Lưu lịch sử giao dịch
      final now = DateFormat("HH:mm dd/MM").format(DateTime.now());
      await TransactionStorage.addTransaction(
        AppModel.Transaction(
          title: "Nạp tiền (Demo)",
          amount: _amount,
          time: now,
        ),
      );

      if (!mounted) return;
      setState(() {
        _walletBalance = newBalance;
        _isLoading = false;
      });

      // Hiển thị Dialog thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 8),
              Text("Thành công"),
            ],
          ),
          content: Text(
            "Bạn đã nạp thành công ${NumberFormat("#,###").format(_amount)}đ vào tài khoản qua $_paymentMethod.\n\n(Đây là giao dịch giả lập phục vụ Demo)",
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text("ĐÓNG", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nạp tiền (Demo)"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nhập số tiền muốn nạp (Tối thiểu 10.000đ)"),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _amount = int.tryParse(val) ?? 0),
                  decoration: InputDecoration(
                    prefixText: "đ ",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
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
                      const Text("Số dư hiện tại:", style: TextStyle(fontSize: 16)),
                      Text(
                        "đ${NumberFormat("#,###").format(_walletBalance)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
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
                const Text("Phương thức thanh toán"),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.deepPurple),
                  title: Text(_paymentMethod ?? "Chọn ngân hàng/Ví"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _choosePaymentMethod,
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_amount >= 10000 && _paymentMethod != null && !_isLoading) ? _handleRecharge : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("XÁC NHẬN NẠP TIỀN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.deepPurple),
                        SizedBox(height: 16),
                        Text("Đang kết nối ngân hàng...", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Vui lòng không thoát ứng dụng"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quickButton(int value) {
    bool isSelected = _amount == value;
    return OutlinedButton(
      onPressed: () => _setQuickAmount(value),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey),
        backgroundColor: isSelected ? Colors.deepPurple.shade50 : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        "${value ~/ 1000}k",
        style: TextStyle(color: isSelected ? Colors.deepPurple : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
