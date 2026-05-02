import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String baseUrl = "http://10.0.2.2:5001/app-do-an-ae40f/us-central1/api";

  static Future<void> sendOtp(String email) async {
    try {
      print("[MÁY THẬT] Đang gửi OTP tới: $email qua $baseUrl/sendOtp");
      
      final res = await http.post(
        Uri.parse("$baseUrl/sendOtp"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 15));

      print("Phản hồi: ${res.statusCode} - ${res.body}");
      if (res.statusCode != 200) {
        throw Exception("Lỗi server: ${res.body}");
      }
    } catch (e) {
      print("Lỗi gửi OTP: $e");
      throw Exception("Không thể kết nối tới máy chủ (IP: 192.168.1.145). \nKiểm tra: 1. Chung WiFi chưa? 2. Đã tắt Firewall máy tính chưa?");
    }
  }

  static Future<bool> verifyOtp(String email, String otp) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/verifyOtp"),
        headers: {"Content-Type": "application/json"},
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
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw Exception("Lỗi: ${res.body}");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối máy chủ");
    }
  }
}
