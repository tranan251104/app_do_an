import 'dart:async';

import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/features/auth/data/firebase_phone_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const PhoneOtpScreen({super.key, required this.phoneNumber});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  PhoneVerificationSession? _session;
  Timer? _resendTimer;
  String _enteredOtp = '';
  String? _normalizedPhone;
  bool _sending = false;
  bool _verifying = false;
  bool _completed = false;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp({bool resend = false}) async {
    if (_sending || _verifying || _completed) return;
    AppLogger.action('PHONE OTP send requested', {
      'phone': AppLogger.mask(widget.phoneNumber),
      'resend': resend,
    });
    setState(() => _sending = true);

    try {
      await AppServices.phoneAuth.requestOtp(
        phoneNumber: widget.phoneNumber,
        forceResendingToken: resend ? _session?.resendToken : null,
        onCodeSent: (session) {
          if (!mounted || _completed) return;
          setState(() {
            _session = session;
            _normalizedPhone = session.phoneNumber;
            _sending = false;
            _enteredOtp = '';
          });
          _startResendCountdown();
          _show('Mã OTP đã được gửi tới ${session.phoneNumber}');
        },
        onAutoVerified: (firebaseIdToken) async {
          AppLogger.success('PHONE_AUTH', 'Phone auto-verification completed');
          _finish(firebaseIdToken);
        },
        onVerificationFailed: (failure) {
          if (!mounted || _completed) return;
          AppLogger.warning('PHONE_AUTH', 'Phone verification failed', {
            'code': failure.code,
          });
          setState(() {
            _sending = false;
            _verifying = false;
          });
          _show(failure.message);
        },
        onAutoRetrievalTimeout: () {
          if (!mounted || _completed) return;
          AppLogger.repo('PHONE_AUTH', 'SMS auto-retrieval timed out');
        },
      );
    } on PhoneAuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _sending = false);
      _show(failure.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'PHONE_AUTH',
        'Unexpected error while sending OTP',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _sending = false);
      _show('Không thể gửi OTP. Vui lòng thử lại.');
    }
  }

  Future<void> _confirmOtp() async {
    final session = _session;
    if (session == null || _enteredOtp.length != 6 || _verifying) return;
    AppLogger.action('PHONE OTP confirm pressed', {
      'otpLength': _enteredOtp.length,
    });
    setState(() => _verifying = true);

    try {
      final firebaseIdToken = await AppServices.phoneAuth.confirmOtp(
        session,
        _enteredOtp,
      );
      AppLogger.success('PHONE_AUTH', 'Phone OTP confirmed');
      _finish(firebaseIdToken);
    } on PhoneAuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _verifying = false);
      _show(failure.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'PHONE_AUTH',
        'Unexpected error while confirming OTP',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _verifying = false);
      _show('Không thể xác nhận OTP. Vui lòng thử lại.');
    }
  }

  void _finish(String firebaseIdToken) {
    if (!mounted || _completed) return;
    _completed = true;
    _resendTimer?.cancel();
    Navigator.of(context).pop(firebaseIdToken);
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    if (mounted) setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone = _normalizedPhone ?? widget.phoneNumber;
    return Scaffold(
      appBar: AppBar(title: const Text('Xác minh số điện thoại')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.sms_outlined,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              Text(
                _session == null
                    ? 'Đang gửi mã OTP tới $displayPhone'
                    : 'Nhập mã OTP đã gửi tới $displayPhone',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (_sending && _session == null)
                const CircularProgressIndicator()
              else if (_session == null)
                OutlinedButton.icon(
                  onPressed: _sending ? null : _sendOtp,
                  icon: const Icon(Icons.refresh),
                  label: const Text('THỬ GỬI LẠI'),
                )
              else ...[
                PinCodeTextField(
                  key: ValueKey(_session),
                  appContext: context,
                  length: 6,
                  autoFocus: true,
                  keyboardType: TextInputType.number,
                  enabled: !_verifying,
                  onChanged: (value) => setState(() => _enteredOtp = value),
                  onCompleted: (_) => _confirmOtp(),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 52,
                    fieldWidth: 42,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _enteredOtp.length == 6 && !_verifying
                      ? _confirmOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('XÁC NHẬN'),
                ),
                TextButton(
                  onPressed: _resendSeconds == 0 && !_sending && !_verifying
                      ? () => _sendOtp(resend: true)
                      : null,
                  child: Text(
                    _resendSeconds == 0
                        ? 'Gửi lại mã OTP'
                        : 'Gửi lại sau $_resendSeconds giây',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
