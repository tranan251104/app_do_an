import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String baseUrl = "https://d865-2402-800-f2e6-e812-d094-616e-5114-c3ae.ngrok-free.app/app-do-an-ae40f/us-central1";

  static Future<void> sendOtp(String email) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/sendOtp"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "ngrok-skip-browser-warning": "any",
        },
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw Exception("Lỗi server: ${res.body}");
    } catch (e) {
      throw Exception("Lỗi gửi OTP: $e");
    }
  }

  // MỚI: Hàm gửi email báo biến động số dư
  static Future<void> sendTransactionEmail({
    required String email,
    required String type,
    required int amount,
    required int balance,
    required String note,
    required String time,
  }) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/sendTransactionEmail"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "any",
        },
        body: jsonEncode({
          "email": email,
          "type": type,
          "amount": amount,
          "balance": balance,
          "note": note,
          "time": time,
        }),
      );
    } catch (e) {
      print("Lỗi gửi email giao dịch: $e");
    }
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/verifyOtp"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "any",
        },
        body: jsonEncode({"email": email, "otp": otp}),
      ).timeout(const Duration(seconds: 15));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> resetPassword(String email, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/resetPassword"),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "any",
        },
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) throw Exception("Lỗi: ${res.body}");
    } catch (e) {
      throw Exception("Lỗi kết nối máy chủ");
    }
  }
}
