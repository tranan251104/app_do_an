import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  // Đã xóa "/api" ở cuối để khớp chính xác với Firebase Emulator của bạn
  static const String baseUrl = "https://5cfa-2402-800-f2b6-6e75-9d4c-f626-9c72-7781.ngrok-free.app/app-do-an-ae40f/us-central1";

  static Future<void> sendOtp(String email) async {
    try {
      print("[NGROK] Đang gửi OTP tới: $email qua $baseUrl/sendOtp");
      
      final res = await http.post(
        Uri.parse("$baseUrl/sendOtp"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "ngrok-skip-browser-warning": "any", // Header bắt buộc để chạy qua Ngrok bản miễn phí
        },
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 15));

      print("Phản hồi: ${res.statusCode} - ${res.body}");
      if (res.statusCode != 200) {
        throw Exception("Lỗi server: ${res.body}");
      }
    } catch (e) {
      print("Lỗi gửi OTP: $e");
      throw Exception("Không thể kết nối tới server qua Ngrok.\nKiểm tra: 1. Link Ngrok đã đúng chưa? 2. Firebase Emulator đã chạy chưa?");
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

      if (res.statusCode != 200) {
        throw Exception("Lỗi: ${res.body}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối máy chủ qua Ngrok");
    }
  }
}
