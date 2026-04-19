import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/VNPAY/vnpay_webview.dart';
import 'package:app_do_an/navigator/VNPAY/vnpay_helper.dart';
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

  final String _vnpayReturnUrl = "https://sandbox.vnpayment.vn/apis/vnpay-demo/";

  String? _paymentMethod;

  final List<String> _banks = [
    "MB Bank",
    "Vietcombank",
    "Techcombank",
    "VPBank",
    "BIDV",
    "Agribank",
    "VNPay"
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

  /// 🔹 Load số dư hiện tại từ SharedPreferences
  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _walletBalance = prefs.getInt("wallet_balance") ?? 0;
    });
  }

  /// 🔹 Lưu số dư mới vào SharedPreferences
  Future<void> _saveBalance(int newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("wallet_balance", newBalance);
  }

  /// 🔹 Update Firestore balance + lịch sử
  Future<void> _updateFirestoreBalance(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = fs.FirebaseFirestore.instance.collection('users').doc(user.uid);

    await fs.FirebaseFirestore.instance.runTransaction((fs.Transaction tx) async {
      final snapshot = await tx.get(docRef);
      final currentBalance = (snapshot.data()?['balance'] ?? 0) as int;
      tx.update(docRef, {'balance': currentBalance + amount});
    });

    // Ghi lịch sử giao dịch
    await docRef.collection('transactions').add({
      'title': 'Nạp tiền từ ${_paymentMethod ?? "Ngân hàng"}',
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
              leading: const Icon(Icons.account_balance, color: Colors.purple),
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

    setState(() {
      _isLoading = true;
    });

    try {
      final url = generateVNPayUrl(
        tmnCode: "7OBZ201B",
        hashSecret: "3OZBQGBZXPH9FW6WQ5U598URUGVT2G9O",
        amount: _amount,
        returnUrl: _vnpayReturnUrl, // Dùng biến duy nhất
        isProduction: false,
      );

      print("🔥 VNPay URL: $url");

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VNPayWebView(
            paymentUrl: url,
            returnUrl: _vnpayReturnUrl, // Truyền returnUrl sang Webview
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
            title: "Nạp tiền từ ${_paymentMethod ?? "Ngân hàng"}",
            amount: result,
            time: now,
          ),
        );

        if (!mounted) return;
        setState(() {
          _walletBalance = newBalance;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nạp $result đ thành công")),
        );

        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thanh toán thất bại hoặc bị huỷ")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nạp tiền"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nhập số tiền (đ)"),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _amount = int.tryParse(val) ?? 0;
                });
              },
              decoration: InputDecoration(
                prefixText: "đ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text("Số dư Ví hiện tại: đ$_walletBalance"),

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

            _paymentMethod == null
                ? ListTile(
                    leading: const Icon(Icons.add, color: Colors.purple),
                    title: const Text("Thêm phương thức thanh toán",
                        style: TextStyle(color: Colors.grey)),
                    onTap: _choosePaymentMethod,
                  )
                : ListTile(
                    leading: const Icon(Icons.account_balance, color: Colors.purple),
                    title: const Text("Phương thức thanh toán"),
                    subtitle: Text(_paymentMethod!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _choosePaymentMethod,
                  ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_amount >= 10000 && _paymentMethod != null && !_isLoading)
                    ? _handleRecharge
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Nạp tiền ngay",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        side: BorderSide(
          color: _amount == value ? Colors.purple : Colors.grey,
        ),
        backgroundColor:
            _amount == value ? Colors.red.shade50 : Colors.transparent,
      ),
      child: Text(
        "${value ~/ 1000}.000",
        style: TextStyle(
          color: _amount == value ? Colors.purple : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
