import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/navigator/model/bankAccount1.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/model/transaction.dart';
import 'package:app_do_an/navigator/service/transaction_storage.dart';
import 'package:app_do_an/navigator/fourth_screen/otp_confirm_screen.dart';
import 'package:app_do_an/navigator/service/otp.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:app_do_an/navigator/fourth_screen/otp_confirm_phone_screen.dart';


class TransferMoneyFormScreen extends StatefulWidget {
  final BankAccount1? account1;
  final BankAccount2? account2;
  final int? presetAmount; // ✅ số tiền fix sẵn cho dịch vụ

  const TransferMoneyFormScreen({
    super.key,
    this.account1,
    this.account2,
    this.presetAmount,
  }) : assert(account1 != null || account2 != null,
            'Phải truyền BankAccount1 hoặc BankAccount2');

  @override
  State<TransferMoneyFormScreen> createState() =>
      _TransferMoneyFormScreenState();
}

class _TransferMoneyFormScreenState extends State<TransferMoneyFormScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _walletBalance = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBalance();

    // Nếu có presetAmount → set sẵn số tiền
    if (widget.presetAmount != null) {
      _amountController.text =
          NumberFormat.decimalPattern().format(widget.presetAmount);
    }

    _amountController.addListener(() => setState(() {}));
    _noteController.addListener(() => setState(() {}));
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletBalance = prefs.getInt("wallet_balance") ?? 0;
    });
  }

  Future<void> _saveBalance(int newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("wallet_balance", newBalance);
  }

  bool get isFormValid {
    final cleanVal = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final entered = int.tryParse(cleanVal) ?? 0;
    return entered > 0 && _errorMessage == null;
  }

  String formatNumber(String s) {
    if (s.isEmpty) return "";
    final val = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (val > _walletBalance) {
      _errorMessage = "Số dư ví không đủ";
    } else {
      _errorMessage = null;
    }
    return NumberFormat.decimalPattern().format(val);
  }

  Widget _buildAccountInfo() {
    if (widget.account1 != null) {
      final account = widget.account1!;
      return Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurpleAccent,
            child: Text(
              account.ownerName.isNotEmpty
                  ? account.ownerName[0].toUpperCase()
                  : "?",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(account.ownerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                "${account.bankName} *${account.accountNumber.substring(account.accountNumber.length - 4)}",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      );
    } else {
      final service = widget.account2!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(service.serviceName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("Nhà cung cấp: ${service.provider}",
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text("Chi tiết: ${service.detail}",
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chuyển đến"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Thông tin tài khoản/dịch vụ
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _buildAccountInfo(),
            ),

            const SizedBox(height: 12),

            // 🔹 Nhập số tiền
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Số tiền",
                      style: TextStyle(color: Colors.black54)),
                  TextField(
                    controller: _amountController,
                    enabled: widget.presetAmount == null, // preset → khóa lại
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                    inputFormatters: widget.presetAmount == null
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              final newText = formatNumber(newValue.text);
                              return newValue.copyWith(
                                text: newText,
                                selection: TextSelection.collapsed(
                                    offset: newText.length),
                              );
                            }),
                          ]
                        : [],
                    decoration: InputDecoration(
                      hintText: "₫",
                      border: InputBorder.none,
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Số dư Ví: ₫${NumberFormat.decimalPattern().format(_walletBalance)}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Nhập mô tả
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mô tả",
                      style: TextStyle(color: Colors.black54)),
                  TextField(
                    controller: _noteController,
                    maxLength: 140,
                    decoration: const InputDecoration(
                      hintText:
                          "Nhập nội dung không dấu, không chứa ký tự đặc biệt",
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Nút tiếp tục
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Nhấn "Tiếp tục", bạn đã đồng ý tuân theo Điều khoản sử dụng và Chính sách bảo mật',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isFormValid
                        ? () async {
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email');
        final userPhone = prefs.getString('phone');

        final cleanVal =
            _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final amount = int.tryParse(cleanVal) ?? 0;

        if (amount <= 0 || amount > _walletBalance) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Số tiền không hợp lệ")),
          );
          return;
        }

        if (userEmail != null && userEmail.isNotEmpty) {
          // ✅ OTP qua email
          await OtpService.sendOtp(userEmail);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpConfirmScreen(
                email: userEmail,
                account1: widget.account1,
                account2: widget.account2,
                amount: amount,
              ),
            ),
          );
        } else if (userPhone != null && userPhone.isNotEmpty) {
          // ✅ OTP qua SMS
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpPhoneConfirmScreen(
                phone: userPhone,
                onVerified: () async {
                  // 👉 Logic xử lý sau khi OTP đúng
                  final newBalance = _walletBalance - amount;
                  await _saveBalance(newBalance);
                  setState(() => _walletBalance = newBalance);

                  final now = DateFormat("HH:mm dd/MM").format(DateTime.now());
                  await TransactionStorage.addTransaction(
                    Transaction(
                      title: widget.account2 != null
                          ? "${widget.account2!.serviceName} - ${widget.account2!.provider}"
                          : "Chuyển tiền cho ${widget.account1!.ownerName}",
                      amount: -amount,
                      time: now,
                    ),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionResultScreen(
                        bankName: widget.account1?.bankName ?? "",
                        accountName: widget.account1?.ownerName ??
                            "${widget.account2!.serviceName} - ${widget.account2!.provider}",
                        amount: amount,
                        time: now,
                        isServiceTransaction: widget.account2 != null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFormValid ? Colors.deepPurpleAccent : Colors.grey.shade400,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text("TIẾP TỤC"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

