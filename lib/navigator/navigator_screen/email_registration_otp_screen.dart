import 'dart:async';

import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/auth/data/email_otp_models.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EmailRegistrationOtpScreen extends StatefulWidget {
  final String email;
  final String registrationFullName;
  final String registrationPassword;

  const EmailRegistrationOtpScreen({
    super.key,
    required this.email,
    required this.registrationFullName,
    required this.registrationPassword,
  });

  @override
  State<EmailRegistrationOtpScreen> createState() =>
      _EmailRegistrationOtpScreenState();
}

class _EmailRegistrationOtpScreenState
    extends State<EmailRegistrationOtpScreen> {
  EmailOtpChallenge? _challenge;
  Timer? _clock;
  String _enteredOtp = '';
  bool _sending = false;
  bool _verifying = false;
  bool _completed = false;
  int _resendSeconds = 0;
  int _expiresSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp({bool resend = false}) async {
    if (_sending || _verifying || _completed) return;
    final current = _challenge;
    if (resend && current == null) return;

    AppLogger.action('EMAIL REGISTRATION OTP send requested', {
      'email': AppLogger.mask(widget.email),
      'resend': resend,
    });
    setState(() => _sending = true);

    try {
      final next = resend
          ? await AppServices.auth.resendEmailRegistrationOtp(
              challengeId: current!.challengeId,
              email: current.email,
            )
          : await AppServices.auth.sendEmailRegistrationOtp(
              email: widget.email,
            );
      if (!mounted || _completed) return;

      setState(() {
        _challenge = next;
        _enteredOtp = '';
        _sending = false;
      });
      _startClock(next);
      _show(
        next.delivery == 'EMAIL'
            ? 'Mã OTP đã được gửi tới email của bạn.'
            : 'Mã OTP demo đã được tạo.',
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      _show(error.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'EMAIL_REGISTRATION_OTP_UI',
        'Unexpected error while sending email OTP',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _sending = false);
      _show('Không thể gửi OTP qua email. Vui lòng thử lại.');
    }
  }

  Future<void> _confirmOtp() async {
    final challenge = _challenge;
    if (challenge == null ||
        _enteredOtp.length != 6 ||
        _verifying ||
        _expiresSeconds == 0) {
      return;
    }

    AppLogger.action('EMAIL REGISTRATION OTP confirm pressed', {
      'email': AppLogger.mask(challenge.email),
      'otpLength': _enteredOtp.length,
    });
    setState(() => _verifying = true);

    try {
      await AppServices.auth.verifyEmailRegistrationOtp(
        challengeId: challenge.challengeId,
        email: challenge.email,
        otp: _enteredOtp,
        fullName: widget.registrationFullName,
        password: widget.registrationPassword,
      );
      AppLogger.success(
        'EMAIL_REGISTRATION_OTP_UI',
        'Email OTP confirmed and account registered',
      );
      _finish(challenge.email);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        if (error.code == 'OTP_EXPIRED') _expiresSeconds = 0;
      });
      _show(error.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'EMAIL_REGISTRATION_OTP_UI',
        'Unexpected error while confirming email OTP',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _verifying = false);
      _show('Không thể xác nhận OTP. Vui lòng thử lại.');
    }
  }

  void _finish(String email) {
    if (!mounted || _completed) return;
    _completed = true;
    _clock?.cancel();
    Navigator.of(context).pop(EmailOtpRegistrationResult(email: email));
  }

  void _startClock(EmailOtpChallenge challenge) {
    _clock?.cancel();
    if (mounted) {
      setState(() {
        _resendSeconds = challenge.resendAfterSeconds;
        _expiresSeconds = challenge.expiresInSeconds;
      });
    }
    _clock = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _completed) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
        if (_expiresSeconds > 0) _expiresSeconds--;
      });
      if (_resendSeconds == 0 && _expiresSeconds == 0) timer.cancel();
    });
  }

  String _duration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenge;
    final displayEmail = challenge?.maskedEmail ?? widget.email;
    return PopScope(
      canPop: !_verifying,
      child: Scaffold(
        appBar: AppBar(title: const Text('Xác thực email')),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 24),
                Text(
                  challenge == null
                      ? 'Đang gửi mã OTP tới $displayEmail'
                      : challenge.delivery == 'EMAIL'
                      ? 'Nhập mã OTP đã gửi tới email $displayEmail'
                      : 'Nhập mã OTP demo cho $displayEmail',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (challenge != null)
                  Text(
                    _expiresSeconds > 0
                        ? 'Mã hết hạn sau ${_duration(_expiresSeconds)}'
                        : 'Mã OTP đã hết hạn',
                    style: TextStyle(
                      color: _expiresSeconds > 0 ? Colors.black54 : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 28),
                if (_sending && challenge == null)
                  const CircularProgressIndicator()
                else if (challenge == null)
                  OutlinedButton.icon(
                    onPressed: _sending ? null : _sendOtp,
                    icon: const Icon(Icons.refresh),
                    label: const Text('THỬ GỬI LẠI'),
                  )
                else ...[
                  if (challenge.demoOtp != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'CHẾ ĐỘ DEMO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            'OTP: ${challenge.demoOtp}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                  PinCodeTextField(
                    key: ValueKey(challenge.challengeId),
                    appContext: context,
                    length: 6,
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    enabled: !_verifying && _expiresSeconds > 0,
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
                    onPressed:
                        _enteredOtp.length == 6 &&
                            !_verifying &&
                            _expiresSeconds > 0
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
                      _sending
                          ? 'Đang gửi lại...'
                          : _resendSeconds == 0
                          ? 'Gửi lại mã OTP'
                          : 'Gửi lại sau ${_duration(_resendSeconds)}',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'OTP đăng ký này được gửi qua email, không gửi bằng thông báo đẩy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
