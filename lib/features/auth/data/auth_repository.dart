import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'email_otp_models.dart';
import 'firebase_phone_auth_service.dart';
import 'phone_otp_models.dart';

class AuthRepository {
  final ApiClient api;
  final TokenStorage tokens;
  final FirebasePhoneAuthService phoneAuth;

  AuthRepository(this.api, this.tokens, this.phoneAuth);

  Future<EmailOtpChallenge> sendEmailRegistrationOtp({
    required String email,
  }) async {
    AppLogger.repo('AUTH', 'EMAIL_REGISTRATION_OTP send start', {
      'email': AppLogger.mask(email),
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/email/send-otp',
        data: {'email': email.trim()},
      );
      final challenge = _emailOtpChallenge(response.data?['data']);
      AppLogger.success('AUTH', 'EMAIL_REGISTRATION_OTP send success', {
        'delivery': challenge.delivery,
        'expiresInSeconds': challenge.expiresInSeconds,
        'resendAfterSeconds': challenge.resendAfterSeconds,
      });
      return challenge;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'EMAIL_REGISTRATION_OTP send failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<EmailOtpChallenge> resendEmailRegistrationOtp({
    required String challengeId,
    required String email,
  }) async {
    AppLogger.repo('AUTH', 'EMAIL_REGISTRATION_OTP resend start', {
      'email': AppLogger.mask(email),
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/email/resend-otp',
        data: {'challengeId': challengeId, 'email': email.trim()},
      );
      final challenge = _emailOtpChallenge(response.data?['data']);
      AppLogger.success('AUTH', 'EMAIL_REGISTRATION_OTP resend success', {
        'delivery': challenge.delivery,
        'expiresInSeconds': challenge.expiresInSeconds,
        'resendAfterSeconds': challenge.resendAfterSeconds,
      });
      return challenge;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'EMAIL_REGISTRATION_OTP resend failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> verifyEmailRegistrationOtp({
    required String challengeId,
    required String email,
    required String otp,
    required String fullName,
    required String password,
    String deviceId = 'flutter-app',
  }) async {
    AppLogger.repo('AUTH', 'EMAIL_REGISTRATION_OTP verify start', {
      'email': AppLogger.mask(email),
      'otpLength': otp.length,
      'fullNameProvided': fullName.trim().isNotEmpty,
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/email/verify-otp',
        data: {
          'challengeId': challengeId,
          'email': email.trim(),
          'otp': otp,
          'fullName': fullName.trim(),
          'password': password,
          'deviceId': deviceId,
        },
      );
      await _saveTokens(response.data?['data']);
      AppLogger.success(
        'AUTH',
        'EMAIL_REGISTRATION_OTP verify and registration success',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'EMAIL_REGISTRATION_OTP verify failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<PhoneOtpChallenge> sendPhoneOtp({
    required String phoneNumber,
    String? fcmToken,
  }) async {
    AppLogger.repo('AUTH', 'PHONE_OTP send start', {
      'phone': AppLogger.mask(phoneNumber),
      'hasFcmToken': fcmToken?.trim().isNotEmpty ?? false,
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/phone/send-otp',
        data: {'phoneNumber': phoneNumber, 'fcmToken': _blankToNull(fcmToken)},
      );
      final challenge = _phoneOtpChallenge(response.data?['data']);
      AppLogger.success('AUTH', 'PHONE_OTP send success', {
        'delivery': challenge.delivery,
        'expiresInSeconds': challenge.expiresInSeconds,
        'resendAfterSeconds': challenge.resendAfterSeconds,
      });
      return challenge;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'PHONE_OTP send failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<PhoneOtpChallenge> resendPhoneOtp({
    required String challengeId,
    required String phoneNumber,
    String? fcmToken,
  }) async {
    AppLogger.repo('AUTH', 'PHONE_OTP resend start', {
      'phone': AppLogger.mask(phoneNumber),
      'hasFcmToken': fcmToken?.trim().isNotEmpty ?? false,
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/phone/resend-otp',
        data: {
          'challengeId': challengeId,
          'phoneNumber': phoneNumber,
          'fcmToken': _blankToNull(fcmToken),
        },
      );
      final challenge = _phoneOtpChallenge(response.data?['data']);
      AppLogger.success('AUTH', 'PHONE_OTP resend success', {
        'delivery': challenge.delivery,
        'expiresInSeconds': challenge.expiresInSeconds,
        'resendAfterSeconds': challenge.resendAfterSeconds,
      });
      return challenge;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'PHONE_OTP resend failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> verifyPhoneOtp({
    required String challengeId,
    required String phoneNumber,
    required String otp,
    String deviceId = 'flutter-app',
    String? fullName,
    String? password,
  }) async {
    AppLogger.repo('AUTH', 'PHONE_OTP verify start', {
      'phone': AppLogger.mask(phoneNumber),
      'otpLength': otp.length,
      'hasRegistrationDetails':
          fullName?.trim().isNotEmpty == true && password?.isNotEmpty == true,
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/phone/verify-otp',
        data: {
          'challengeId': challengeId,
          'phoneNumber': phoneNumber,
          'otp': otp,
          'deviceId': deviceId,
          if (_blankToNull(fullName) case final registrationName?)
            'fullName': registrationName,
          if (_blankToNull(password) case final registrationPassword?)
            'password': registrationPassword,
        },
      );
      await _saveTokens(response.data?['data']);
      AppLogger.success('AUTH', 'PHONE_OTP verify success');
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'PHONE_OTP verify failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> linkPhone({
    required String firebaseIdToken,
    required String currentPassword,
  }) async {
    AppLogger.repo('AUTH', 'LINK_PHONE start');
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/me/phone/link',
        data: {
          'firebaseIdToken': firebaseIdToken,
          'currentPassword': currentPassword,
        },
      );
      final data = Map<String, dynamic>.from(
        response.data?['data'] as Map? ?? const <String, dynamic>{},
      );
      AppLogger.success('AUTH', 'LINK_PHONE success', {
        'phone': AppLogger.mask(data['phone']?.toString()),
        'verified': data['verified'],
      });
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'LINK_PHONE failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    AppLogger.repo('AUTH', 'LOGIN start', {
      'identifier': AppLogger.mask(identifier),
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
          'deviceId': 'flutter-app',
        },
      );
      await _saveTokens(response.data?['data']);
      AppLogger.success('AUTH', 'LOGIN success');
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'LOGIN failed',
        error: error,
        stackTrace: stackTrace,
        data: {'identifier': AppLogger.mask(identifier)},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> logout() async {
    AppLogger.repo('AUTH', 'LOGOUT start');
    final refresh = await tokens.refreshToken();
    try {
      await api.dio.post('/auth/logout', data: {'refreshToken': refresh});
      AppLogger.success('AUTH', 'Server LOGOUT success');
    } catch (error) {
      AppLogger.warning(
        'AUTH',
        'Server LOGOUT failed; continuing with local logout',
        {'error': error.toString()},
      );
      // Local logout must still succeed if the server cannot be reached.
    } finally {
      await tokens.clear();
      try {
        await phoneAuth.signOut();
      } catch (error) {
        AppLogger.warning('AUTH', 'Firebase sign-out failed', {
          'error': error.toString(),
        });
      }
      AppLogger.success('AUTH', 'LOGOUT complete locally');
    }
  }

  Future<void> forgotPasswordRequest(String identifier) async {
    AppLogger.repo('AUTH', 'FORGOT_PASSWORD request start', {
      'identifier': AppLogger.mask(identifier),
    });
    try {
      await api.dio.post(
        '/auth/forgot-password/request',
        data: {'identifier': identifier},
      );
      AppLogger.success('AUTH', 'FORGOT_PASSWORD request success');
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'FORGOT_PASSWORD request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<String> forgotPasswordVerify(String identifier, String otp) async {
    AppLogger.repo('AUTH', 'FORGOT_PASSWORD verify OTP start', {
      'identifier': AppLogger.mask(identifier),
      'otpLength': otp.length,
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/auth/forgot-password/verify',
        data: {'identifier': identifier, 'otp': otp},
      );
      final resetToken =
          response.data?['data']?['resetToken']?.toString() ?? '';
      AppLogger.success('AUTH', 'FORGOT_PASSWORD verify OTP success', {
        'resetTokenReceived': resetToken.isNotEmpty,
      });
      return resetToken;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'FORGOT_PASSWORD verify OTP failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> forgotPasswordReset(
    String resetToken,
    String newPassword,
  ) async {
    AppLogger.repo('AUTH', 'FORGOT_PASSWORD reset start', {
      'hasResetToken': resetToken.isNotEmpty,
      'newPasswordLength': newPassword.length,
    });
    try {
      await api.dio.post(
        '/auth/forgot-password/reset',
        data: {'resetToken': resetToken, 'newPassword': newPassword},
      );
      AppLogger.success('AUTH', 'FORGOT_PASSWORD reset success');
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'FORGOT_PASSWORD reset failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    AppLogger.repo('AUTH', 'CHANGE_PASSWORD start', {
      'currentPasswordLength': currentPassword.length,
      'newPasswordLength': newPassword.length,
    });
    try {
      await api.dio.post(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      AppLogger.success('AUTH', 'CHANGE_PASSWORD success');
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH',
        'CHANGE_PASSWORD failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> _saveTokens(dynamic data) async {
    AppLogger.repo('AUTH', 'Validating auth response tokens');
    if (data is! Map ||
        data['accessToken'] == null ||
        data['refreshToken'] == null) {
      AppLogger.error(
        'AUTH',
        'Auth response is missing accessToken/refreshToken',
      );
      throw const FormatException('Phản hồi đăng nhập không hợp lệ');
    }
    await tokens.save(
      accessToken: data['accessToken'].toString(),
      refreshToken: data['refreshToken'].toString(),
    );
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static PhoneOtpChallenge _phoneOtpChallenge(dynamic data) {
    if (data is! Map) {
      throw const FormatException('Phản hồi gửi OTP không hợp lệ');
    }
    return PhoneOtpChallenge.fromJson(Map<String, dynamic>.from(data));
  }

  static EmailOtpChallenge _emailOtpChallenge(dynamic data) {
    if (data is! Map) {
      throw const FormatException('Phản hồi gửi OTP email không hợp lệ');
    }
    return EmailOtpChallenge.fromJson(Map<String, dynamic>.from(data));
  }
}
