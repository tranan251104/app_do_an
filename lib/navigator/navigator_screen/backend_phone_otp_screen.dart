import 'dart:async';

import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/auth/data/phone_otp_models.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class BackendPhoneOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? registrationFullName;
  final String? registrationPassword;

  const BackendPhoneOtpScreen({
    super.key,
    required this.phoneNumber,
    this.registrationFullName,
    this.registrationPassword,
  }) : assert(
         (registrationFullName == null) == (registrationPassword == null),
         'Registration full name and password must be provided together.',
       );

  @override
  State<BackendPhoneOtpScreen> createState() => _BackendPhoneOtpScreenState();
}

class _BackendPhoneOtpScreenState extends State<BackendPhoneOtpScreen> {
  PhoneOtpChallenge? _challenge;
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

    AppLogger.action('BACKEND PHONE OTP send requested', {
      'phone': AppLogger.mask(widget.phoneNumber),
      'resend': resend,
    });
    setState(() => _sending = true);

    try {
      final fcmToken = await NotificationService.currentFcmToken();
      if (!mounted || _completed) return;
      final next = resend
          ? await AppServices.auth.resendPhoneOtp(
              challengeId: current!.challengeId,
              phoneNumber: current.phoneNumber,
              fcmToken: fcmToken,
            )
          : await AppServices.auth.sendPhoneOtp(
              phoneNumber: widget.phoneNumber,
              fcmToken: fcmToken,
            );
      if (!mounted || _completed) return;

      setState(() {
        _challenge = next;
        _enteredOtp = '';
        _sending = false;
      });
      _startClock(next);
      _show(
        next.delivery == 'FCM'
            ? 'Mã OTP đã được gửi tới thiết bị của bạn.'
            : 'Mã OTP demo đã được tạo.',
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      _show(error.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'PHONE_OTP_UI',
        'Unexpected error while sending backend OTP',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _sending = false);
      _show('Không thể gửi OTP. Vui lòng thử lại.');
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

    AppLogger.action('BACKEND PHONE OTP confirm pressed', {
      'otpLength': _enteredOtp.length,
    });
    setState(() => _verifying = true);

    try {
      await AppServices.auth.verifyPhoneOtp(
        challengeId: challenge.challengeId,
        phoneNumber: challenge.phoneNumber,
        otp: _enteredOtp,
        fullName: widget.registrationFullName,
        password: widget.registrationPassword,
      );
      AppLogger.success('PHONE_OTP_UI', 'Backend phone OTP confirmed');
      _finish(challenge.phoneNumber);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        if (error.code == 'OTP_EXPIRED') _expiresSeconds = 0;
      });
      _show(error.message);
    } catch (error, stackTrace) {
      AppLogger.error(
        'PHONE_OTP_UI',
        'Unexpected error while confirming backend OTP',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _verifying = false);
      _show('Không thể xác nhận OTP. Vui lòng thử lại.');
    }
  }

  void _finish(String phoneNumber) {
    if (!mounted || _completed) return;
    _completed = true;
    _clock?.cancel();
    Navigator.of(context).pop(PhoneOtpLoginResult(phoneNumber: phoneNumber));
  }

  void _startClock(PhoneOtpChallenge challenge) {
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
    final displayPhone = challenge?.maskedPhone ?? widget.phoneNumber;
    return PopScope(
      canPop: !_verifying,
      child: Scaffold(
        appBar: AppBar(title: const Text('Xác thực số điện thoại')),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.phonelink_lock_outlined,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 24),
                Text(
                  challenge == null
                      ? 'Đang tạo mã OTP cho $displayPhone'
                      : challenge.delivery == 'FCM'
                      ? 'Nhập mã OTP đã gửi tới thiết bị cho $displayPhone'
                      : 'Nhập mã OTP demo cho $displayPhone',
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
                  'Đây là luồng OTP mô phỏng qua API/FCM, không xác minh quyền sở hữu SIM.',
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
