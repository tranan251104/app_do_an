import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class PayOSService {
  static const String clientId = "45a81702-2f34-4eae-a0f2-82010d44fa15";
  static const String apiKey = "f5595d93-e1d3-46d0-8536-a184a8f472ab";
  static const String checksumKey = "3b1637efcef8750b38c241a0e4890dc66dfee2cae58913b5a69e0be31343cd7e";

  static const String _baseUrl = "https://api-merchant.payos.vn";

  // 1. NẠP TIỀN (Tạo link thanh toán QR)
  static Future<String?> createPaymentLink({
    required int amount,
    required String description,
    required String returnUrl,
  }) async {
    final int orderCode = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final Map<String, dynamic> params = {
      "amount": amount,
      "cancelUrl": returnUrl,
      "description": description,
      "orderCode": orderCode,
      "returnUrl": returnUrl,
    };

    final sortedKeys = params.keys.toList()..sort();
    final String signData = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    final hmac = Hmac(sha256, utf8.encode(checksumKey));
    final String signature = hmac.convert(utf8.encode(signData)).toString();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/v2/payment-requests"),
        headers: {
          "Content-Type": "application/json",
          "x-client-id": clientId,
          "x-api-key": apiKey,
        },
        body: jsonEncode({...params, "signature": signature}),
      );
      final result = jsonDecode(response.body);
      if (result["code"] == "00") return result["data"]["checkoutUrl"];
    } catch (e) {
      print("❌ Connection Error (Payment): $e");
    }
    return null;
  }

  // 2. CHUYỂN TIỀN ĐI (Chi hộ tới STK thật)
  static Future<bool> disburse({
    required int amount,
    required String accountNumber,
    required String bankName,
    required String accountName,
    required String description,
  }) async {
    // 1. Tạo externalId duy nhất
    final String externalId = DateTime.now().millisecondsSinceEpoch.toString();
    final String bin = getBankBin(bankName);

    // 2. Dữ liệu Body gửi đi
    final Map<String, dynamic> bodyData = {
      "amount": amount,
      "description": description,
      "accountNumber": accountNumber,
      "bin": bin,
      "accountName": accountName,
      "externalId": externalId,
    };

    // 3. TẠO CHỮ KÝ (Sửa lại thứ tự theo chuẩn Disbursement)
    // Cấu trúc: accountNumber + amount + description + bin + externalId
    final String rawSignData = "accountNumber=$accountNumber&amount=$amount&description=$description&bin=$bin&externalId=$externalId";

    final hmac = Hmac(sha256, utf8.encode(checksumKey));
    final String signature = hmac.convert(utf8.encode(rawSignData)).toString();

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/v2/disbursements"),
        headers: {
          "Content-Type": "application/json",
          "x-client-id": clientId,
          "x-api-key": apiKey,
        },
        body: jsonEncode({
          ...bodyData,
          "signature": signature,
        }),
      );

      // In Debug để kiểm soát tình hình
      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        if (result["code"] == "00" || result["error"] == 0) {
          print("✅ Chi tiền thành công!");
          return true;
        } else {
          print("❌ PayOS báo lỗi: ${result["desc"]}");
          return false;
        }
      } else {
        print("❌ Lỗi HTTP: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Connection Error (Disburse): $e");
      return false;
    }
  }

  static String getBankBin(String bankName) {
    final name = bankName.toLowerCase();
    if (name.contains("mb")) return "970422";
    if (name.contains("vietcombank") || name.contains("vcb")) return "970436";
    if (name.contains("techcombank") || name.contains("tcb")) return "970407";
    if (name.contains("vpbank") || name.contains("vpb")) return "970432";
    if (name.contains("bidv")) return "970418";
    if (name.contains("agribank")) return "970405";
    if (name.contains("vietinbank")) return "970415";
    return "970422"; // Mặc định MB
  }
}
