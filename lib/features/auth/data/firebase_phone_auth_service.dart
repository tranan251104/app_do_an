import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PhoneAuthFailure implements Exception {
  final String code;
  final String message;

  const PhoneAuthFailure({required this.code, required this.message});

  factory PhoneAuthFailure.fromFirebase(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-phone-number' => 'Số điện thoại không hợp lệ.',
      'invalid-verification-code' => 'Mã OTP không chính xác.',
      'session-expired' ||
      'code-expired' => 'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.',
      'too-many-requests' =>
        'Bạn đã yêu cầu quá nhiều lần. Vui lòng thử lại sau.',
      'quota-exceeded' =>
        'Hệ thống đã đạt giới hạn gửi SMS. Vui lòng thử lại sau.',
      'network-request-failed' =>
        'Không thể kết nối Firebase. Vui lòng kiểm tra mạng.',
      'app-not-authorized' || 'operation-not-allowed' =>
        'Đăng nhập bằng điện thoại chưa được cấu hình trên Firebase.',
      'captcha-check-failed' =>
        'Không thể xác minh ứng dụng. Vui lòng thử lại.',
      _ => error.message ?? 'Không thể xác minh số điện thoại.',
    };
    return PhoneAuthFailure(code: error.code, message: message);
  }

  @override
  String toString() => message;
}

class PhoneVerificationSession {
  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final ConfirmationResult? _webConfirmation;

  const PhoneVerificationSession._({
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
    ConfirmationResult? webConfirmation,
  }) : _webConfirmation = webConfirmation;
}

class FirebasePhoneAuthService {
  final FirebaseAuth _auth;

  FirebasePhoneAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  static String normalizeVietnamesePhone(String rawPhone) {
    var phone = rawPhone.trim().replaceAll(RegExp(r'[\s().-]'), '');
    if (phone.startsWith('00')) {
      phone = '+${phone.substring(2)}';
    } else if (phone.startsWith('0')) {
      phone = '+84${phone.substring(1)}';
    } else if (phone.startsWith('84')) {
      phone = '+$phone';
    }

    if (!RegExp(r'^\+84[1-9][0-9]{7,9}$').hasMatch(phone)) {
      throw const PhoneAuthFailure(
        code: 'invalid-phone-number',
        message: 'Số điện thoại Việt Nam không hợp lệ.',
      );
    }
    return phone;
  }

  Future<void> requestOtp({
    required String phoneNumber,
    required ValueChanged<PhoneVerificationSession> onCodeSent,
    required FutureOr<void> Function(String firebaseIdToken) onAutoVerified,
    required ValueChanged<PhoneAuthFailure> onVerificationFailed,
    VoidCallback? onAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    final normalizedPhone = normalizeVietnamesePhone(phoneNumber);

    if (kIsWeb) {
      try {
        final confirmation = await _auth.signInWithPhoneNumber(normalizedPhone);
        onCodeSent(
          PhoneVerificationSession._(
            phoneNumber: normalizedPhone,
            webConfirmation: confirmation,
          ),
        );
      } on FirebaseAuthException catch (error) {
        onVerificationFailed(PhoneAuthFailure.fromFirebase(error));
      }
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      throw const PhoneAuthFailure(
        code: 'unsupported-platform',
        message:
            'Xác minh số điện thoại chỉ được hỗ trợ trên Android, iOS và Web.',
      );
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (credential) async {
          try {
            final token = await _signInAndGetFreshIdToken(credential);
            await onAutoVerified(token);
          } on FirebaseAuthException catch (error) {
            onVerificationFailed(PhoneAuthFailure.fromFirebase(error));
          } on PhoneAuthFailure catch (error) {
            onVerificationFailed(error);
          }
        },
        verificationFailed: (error) {
          onVerificationFailed(PhoneAuthFailure.fromFirebase(error));
        },
        codeSent: (verificationId, resendToken) {
          onCodeSent(
            PhoneVerificationSession._(
              phoneNumber: normalizedPhone,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        },
        codeAutoRetrievalTimeout: (_) => onAutoRetrievalTimeout?.call(),
      );
    } on FirebaseAuthException catch (error) {
      onVerificationFailed(PhoneAuthFailure.fromFirebase(error));
    }
  }

  Future<String> confirmOtp(
    PhoneVerificationSession session,
    String smsCode,
  ) async {
    if (!RegExp(r'^\d{6}$').hasMatch(smsCode)) {
      throw const PhoneAuthFailure(
        code: 'invalid-verification-code',
        message: 'Mã OTP phải gồm 6 chữ số.',
      );
    }

    try {
      if (session._webConfirmation != null) {
        final credential = await session._webConfirmation.confirm(smsCode);
        return _freshIdToken(credential.user);
      }

      final verificationId = session.verificationId;
      if (verificationId == null || verificationId.isEmpty) {
        throw const PhoneAuthFailure(
          code: 'missing-verification-id',
          message: 'Phiên xác minh không hợp lệ. Vui lòng gửi lại OTP.',
        );
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return _signInAndGetFreshIdToken(credential);
    } on FirebaseAuthException catch (error) {
      throw PhoneAuthFailure.fromFirebase(error);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<String> _signInAndGetFreshIdToken(
    PhoneAuthCredential credential,
  ) async {
    final userCredential = await _auth.signInWithCredential(credential);
    return _freshIdToken(userCredential.user);
  }

  Future<String> _freshIdToken(User? user) async {
    if (user == null) {
      throw const PhoneAuthFailure(
        code: 'firebase-user-missing',
        message: 'Firebase không trả về người dùng đã xác minh.',
      );
    }
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw const PhoneAuthFailure(
        code: 'firebase-token-missing',
        message: 'Không lấy được phiên xác minh Firebase.',
      );
    }
    return token;
  }
}
