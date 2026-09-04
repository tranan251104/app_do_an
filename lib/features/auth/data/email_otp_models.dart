class EmailOtpChallenge {
  final String challengeId;
  final String email;
  final String maskedEmail;
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String delivery;
  final String? demoOtp;

  const EmailOtpChallenge({
    required this.challengeId,
    required this.email,
    required this.maskedEmail,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    required this.delivery,
    this.demoOtp,
  });

  factory EmailOtpChallenge.fromJson(Map<String, dynamic> json) {
    final challengeId = json['challengeId']?.toString() ?? '';
    final email = json['email']?.toString() ?? '';
    if (challengeId.isEmpty || email.isEmpty) {
      throw const FormatException(
        'Phản hồi gửi OTP thiếu challengeId hoặc email',
      );
    }

    final demoOtp = json['demoOtp']?.toString().trim();
    return EmailOtpChallenge(
      challengeId: challengeId,
      email: email,
      maskedEmail: json['maskedEmail']?.toString() ?? email,
      expiresInSeconds: _nonNegativeInt(json['expiresInSeconds'], 300),
      resendAfterSeconds: _nonNegativeInt(json['resendAfterSeconds'], 60),
      delivery: (json['delivery']?.toString() ?? 'EMAIL').toUpperCase(),
      demoOtp: demoOtp == null || demoOtp.isEmpty ? null : demoOtp,
    );
  }

  static int _nonNegativeInt(dynamic value, int fallback) {
    final parsed = value is num ? value.toInt() : int.tryParse('$value');
    return parsed == null || parsed < 0 ? fallback : parsed;
  }
}

class EmailOtpRegistrationResult {
  final String email;

  const EmailOtpRegistrationResult({required this.email});
}
