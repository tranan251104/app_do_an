import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String baseUrl = "http://10.71.181.80:5001/app-do-an-ae40f/us-central1/api";

  static Future<void> sendOtp(String email) async {
    final res = await http.post(
      Uri.parse("$baseUrl/sendOtp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),   // encode Map, không encode chuỗi
    );

    print("🔹 sendOtp status: ${res.statusCode}");
    print("🔹 sendOtp body: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Lỗi gửi OTP: ${res.body}");
    }
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse("$baseUrl/verifyOtp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),  // ✅ chuẩn
    );

    print("🔹 verifyOtp status: ${res.statusCode}");
    print("🔹 verifyOtp body: ${res.body}");

    return res.statusCode == 200;
  }

    static Future<void> resetPassword(String email, String newPassword) async {
    final res = await http.post(
      Uri.parse("$baseUrl/resetPassword"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "newPassword": newPassword}),
    );

    print("🔹 resetPassword status: ${res.statusCode}");
    print("🔹 resetPassword body: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Lỗi reset password: ${res.body}");
    }
  }
}


