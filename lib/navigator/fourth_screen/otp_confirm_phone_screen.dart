import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpPhoneConfirmScreen extends StatefulWidget {
  final String phone;
  final Function onVerified; // callback khi OTP thành công

  const OtpPhoneConfirmScreen({
    super.key,
    required this.phone,
    required this.onVerified,
  });

  @override
  State<OtpPhoneConfirmScreen> createState() => _OtpPhoneConfirmScreenState();
}

class _OtpPhoneConfirmScreenState extends State<OtpPhoneConfirmScreen> {
  final _auth = FirebaseAuth.instance;
  String? _verificationId;
  String _enteredOtp = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    final formattedPhone =
        widget.phone.startsWith("+84") ? widget.phone : "+84${widget.phone.substring(1)}";

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Lỗi: ${e.message}")),
        );
      },
      codeSent: (verId, _) {
        setState(() => _verificationId = verId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP đã được gửi!")),
        );
      },
      codeAutoRetrievalTimeout: (verId) => _verificationId = verId,
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) return;

    setState(() => _loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _enteredOtp,
      );

      await _auth.signInWithCredential(credential);

      setState(() => _loading = false);

      // Gọi callback để thực hiện trừ tiền và lưu lịch sử
      // Không gọi Navigator.pop ở đây để transfer_money_form_screen tự chuyển sang ResultScreen
      await widget.onVerified(); 

    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Sai OTP hoặc lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác nhận OTP (SĐT)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Mã OTP đã gửi đến ${widget.phone}",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            PinCodeTextField(
              appContext: context,
              length: 6,
              autoFocus: true,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _enteredOtp = value),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _enteredOtp.length == 6 && !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("XÁC NHẬN"),
            ),
          ],
        ),
      ),
    );
  }
}
