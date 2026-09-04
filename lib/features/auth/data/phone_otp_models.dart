import '../../../core/network/api_exception.dart';

class PhoneOtpChallenge {
  final String challengeId;
  final String phoneNumber;
  final String maskedPhone;
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String delivery;
  final String? demoOtp;

  const PhoneOtpChallenge({
    required this.challengeId,
    required this.phoneNumber,
    required this.maskedPhone,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    required this.delivery,
    this.demoOtp,
  });

  factory PhoneOtpChallenge.fromJson(Map<String, dynamic> json) {
    final challengeId = json['challengeId']?.toString() ?? '';
    final phoneNumber = json['phoneNumber']?.toString() ?? '';
    if (challengeId.isEmpty || phoneNumber.isEmpty) {
      throw const FormatException(
        'Phản hồi gửi OTP thiếu challengeId hoặc phoneNumber',
      );
    }

    final demoOtp = json['demoOtp']?.toString().trim();
    return PhoneOtpChallenge(
      challengeId: challengeId,
      phoneNumber: phoneNumber,
      maskedPhone: json['maskedPhone']?.toString() ?? phoneNumber,
      expiresInSeconds: _positiveInt(json['expiresInSeconds'], fallback: 180),
      resendAfterSeconds: _positiveInt(
        json['resendAfterSeconds'],
        fallback: 60,
      ),
      delivery: json['delivery']?.toString().toUpperCase() ?? 'UNKNOWN',
      demoOtp: demoOtp == null || demoOtp.isEmpty ? null : demoOtp,
    );
  }

  static int _positiveInt(dynamic value, {required int fallback}) {
    final parsed = value is num ? value.toInt() : int.tryParse('$value');
    return parsed != null && parsed > 0 ? parsed : fallback;
  }
}

class PhoneOtpLoginResult {
  final String phoneNumber;

  const PhoneOtpLoginResult({required this.phoneNumber});
}

/// Mirrors the backend's PhoneNumberNormalizer so invalid values can be
/// rejected before a challenge is created. The backend remains authoritative.
String normalizeVietnamesePhone(String rawPhone) {
  var phone = rawPhone.trim().replaceAll(RegExp(r'[\s().-]'), '');
  if (phone.startsWith('00')) {
    phone = '+${phone.substring(2)}';
  } else if (phone.startsWith('0')) {
    phone = '+84${phone.substring(1)}';
  } else if (phone.startsWith('84')) {
    phone = '+$phone';
  }

  if (!RegExp(r'^\+84[1-9][0-9]{7,9}$').hasMatch(phone)) {
    throw const ApiException(
      code: 'PHONE_INVALID',
      message: 'Số điện thoại Việt Nam không hợp lệ.',
      statusCode: 400,
    );
  }
  return phone;
}
