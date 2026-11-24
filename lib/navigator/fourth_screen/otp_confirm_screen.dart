import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/features/smart_otp/presentation/smart_otp_flow.dart';

class OtpConfirmScreen extends StatefulWidget {
  final String transferId;
  final String reference;
  final String receiverName;
  final String receiverWalletCode;
  final int amount;
  final DateTime? expiresAt;
  final bool external;
  final String? bankName;
  final String? otpChannel;

  const OtpConfirmScreen({
    super.key,
    required this.transferId,
    required this.reference,
    required this.receiverName,
    required this.receiverWalletCode,
    required this.amount,
    this.expiresAt,
    this.external = false,
    this.bankName,
    this.otpChannel,
  });

  @override
  State<OtpConfirmScreen> createState() => _OtpConfirmScreenState();
}

class _OtpConfirmScreenState extends State<OtpConfirmScreen> {

  bool _loading = false;
  bool _resending = false;

  String get _tag => widget.external ? 'EXTERNAL_TRANSFER_UI' : 'TRANSFER_UI';

  String get _otpInstruction =>
      'Bấm Xác thực, nhập PIN Smart OTP trên thiết bị để ký giao dịch. '
      'PIN không được gửi tới Backend.';

  Future<void> _verifyOtp() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final proof=await SmartOtpFlow.authorize(context,widget.transferId);
      if (!mounted || proof == null) return;
      final result=widget.external
          ? await AppServices.transfer.confirmExternal(widget.transferId,proof)
          : await AppServices.transfer.confirm(widget.transferId,proof);
      final status=result['status']?.toString()??'';
      if(status!='COMPLETED') { _show('Giao dịch chưa hoàn tất: $status'); return; }
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => TransactionResultScreen(
          transactionId: widget.transferId,
          bankName: widget.external
              ? (result['bankName']?.toString() ?? widget.bankName ?? 'Ngân hàng') : 'ANPAY',
          accountName: widget.external
              ? (result['accountName']?.toString() ?? widget.receiverName)
              : (result['receiverDisplayName']?.toString() ?? widget.receiverName),
          amount: (result['amount'] as num?)?.toInt() ?? widget.amount,
          time: DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now()),
          isSimulation: widget.external,
          providerReference: result['providerReference']?.toString(),
        ),
      ));
    } on ApiException catch(e) {
      _show(e.message);
    } catch(_) {
      _show('Không xác nhận được giao dịch. Hãy kiểm tra trạng thái trước khi thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if(_resending) return;
    setState(() => _resending=true);
    try {
      if(widget.external) {
        await AppServices.transfer.resendExternalOtp(widget.transferId);
      } else {
        await AppServices.transfer.resendOtp(widget.transferId);
      }
      _show('Đã tạo lại yêu cầu xác thực Smart OTP.');
    } on ApiException catch(e) { _show(e.message); }
    finally { if(mounted) setState(() => _resending=false); }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final expiresText = widget.expiresAt == null
        ? null
        : DateFormat('HH:mm:ss').format(widget.expiresAt!.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.external ? 'Smart OTP chuyển ngân hàng' : 'Smart OTP chuyển tiền',
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (widget.external)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MÔ PHỎNG: Khi ký Smart OTP hợp lệ, Backend trừ tiền khỏi ví AnPay demo. Ngân hàng không nhận tiền thật.',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(_otpInstruction, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            if (widget.external && widget.bankName != null)
              Text(
                widget.bankName!,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              '${widget.receiverName} · ${widget.receiverWalletCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (widget.reference.isNotEmpty)
              Text(
                'Mã GD: ${widget.reference}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (expiresText != null)
              Text(
                'Yêu cầu xác thực hết hạn lúc $expiresText',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 32),
            const Icon(Icons.verified_user, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 18),
            TextButton(
              onPressed: _resending ? null : _resendOtp,
              child: Text(_resending ? 'Đang làm mới...' : 'Làm mới xác thực'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: !_loading ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.external
                          ? 'XÁC THỰC SMART OTP'
                          : 'XÁC THỰC SMART OTP',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
