import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpConfirmScreen extends StatefulWidget {
  final String transferId;
  final String reference;
  final String receiverName;
  final String receiverWalletCode;
  final int amount;
  final DateTime? expiresAt;
  final bool external;
  final String? bankName;

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
  });

  @override
  State<OtpConfirmScreen> createState() => _OtpConfirmScreenState();
}

class _OtpConfirmScreenState extends State<OtpConfirmScreen> {
  String _enteredOtp = '';
  bool _loading = false;
  bool _resending = false;

  String get _tag => widget.external ? 'EXTERNAL_TRANSFER_UI' : 'TRANSFER_UI';

  Future<void> _verifyOtp() async {
    AppLogger.action(
      widget.external
          ? 'EXTERNAL_TRANSFER: CONFIRM OTP button pressed'
          : 'TRANSFER: CONFIRM OTP button pressed',
      {
        'transferId': AppLogger.mask(widget.transferId),
        'otpLength': _enteredOtp.length,
      },
    );

    if (_enteredOtp.length != 6 || _loading) {
      AppLogger.warning(_tag, 'OTP confirm ignored', {
        'otpLength': _enteredOtp.length,
        'loading': _loading,
      });
      return;
    }

    setState(() => _loading = true);
    try {
      AppLogger.repo(
        _tag,
        widget.external
            ? 'Calling TransferRepository.confirmExternal'
            : 'Calling TransferRepository.confirm',
      );

      final result = widget.external
          ? await AppServices.transfer.confirmExternal(
              widget.transferId,
              _enteredOtp,
            )
          : await AppServices.transfer.confirm(widget.transferId, _enteredOtp);

      final status = result['status']?.toString() ?? '';
      if (status != 'COMPLETED') {
        AppLogger.warning(
          _tag,
          'Transfer confirm returned non-completed status',
          {'status': status},
        );
        _show('Giao dịch chưa hoàn tất: $status');
        return;
      }

      AppLogger.success(_tag, 'Transfer completed; opening result screen', {
        'status': status,
        'amount': result['amount'],
        'bank': result['bankName']?.toString(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionResultScreen(
            bankName: widget.external
                ? (result['bankName']?.toString() ??
                      widget.bankName ??
                      'Ngân hàng')
                : 'ANPAY',
            accountName: widget.external
                ? (result['accountName']?.toString() ?? widget.receiverName)
                : (result['receiverDisplayName']?.toString() ??
                      widget.receiverName),
            amount: (result['amount'] as num?)?.toInt() ?? widget.amount,
            time: DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now()),
            isSimulation: widget.external,
            providerReference: result['providerReference']?.toString(),
          ),
        ),
      );
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        _tag,
        'OTP confirmation failed',
        error: e,
        stackTrace: stackTrace,
        data: {'code': e.code, 'status': e.statusCode},
      );
      _show(e.message);
    } catch (e, stackTrace) {
      AppLogger.error(
        _tag,
        'OTP confirmation failed unexpectedly',
        error: e,
        stackTrace: stackTrace,
      );
      _show('Không thể xác nhận giao dịch: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    AppLogger.action(
      widget.external
          ? 'EXTERNAL_TRANSFER: RESEND OTP button pressed'
          : 'TRANSFER: RESEND OTP button pressed',
      {'transferId': AppLogger.mask(widget.transferId)},
    );
    if (_resending) return;

    setState(() => _resending = true);
    try {
      if (widget.external) {
        await AppServices.transfer.resendExternalOtp(widget.transferId);
      } else {
        await AppServices.transfer.resendOtp(widget.transferId);
      }
      AppLogger.success(_tag, 'Resend OTP request completed');
      _show('Đã yêu cầu gửi lại OTP');
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        _tag,
        'Resend OTP failed',
        error: e,
        stackTrace: stackTrace,
      );
      _show(e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
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
          widget.external ? 'Xác nhận chuyển ngân hàng' : 'Xác nhận OTP',
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
                  'MÔ PHỎNG: OTP đúng sẽ làm Backend trừ tiền khỏi ví AnPay demo. Không có tiền thật được chuyển tới ngân hàng.',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              widget.external
                  ? 'Nhập OTP để Backend xác nhận giao dịch ngân hàng mô phỏng'
                  : 'Nhập mã xác thực để backend hoàn tất giao dịch chuyển tiền',
              textAlign: TextAlign.center,
            ),
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
                'OTP hết hạn lúc $expiresText',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _enteredOtp = value),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _resending ? null : _resendOtp,
              child: Text(_resending ? 'Đang gửi lại...' : 'Gửi lại OTP'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _enteredOtp.length == 6 && !_loading
                  ? _verifyOtp
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.external
                          ? 'XÁC NHẬN MÔ PHỎNG'
                          : 'XÁC NHẬN CHUYỂN TIỀN',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
