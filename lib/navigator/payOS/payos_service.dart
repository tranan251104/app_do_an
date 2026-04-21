import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class PayOSService {
  static const String clientId = "45a81702-2f34-4eae-a0f2-82010d44fa15";
  static const String apiKey = "f5595d93-e1d3-46d0-8536-a184a8f472ab";
  static const String checksumKey = "3b1637efcef8750b38c241a0e4890dc66dfee2cae58913b5a69e0be31343cd7e";

  static const String _baseUrl = "https://api-merchant.payos.vn";

  static Future<String?> createPaymentLink({
    required int amount,
    required String description,
    required String returnUrl,
  }) async {
    // 1. Tạo orderCode duy nhất
    final int orderCode = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String cleanUrl = returnUrl.trim();

    // 2. Tạo Map dữ liệu và sắp xếp Key theo Alphabet
    final Map<String, dynamic> params = {
      "amount": amount,
      "cancelUrl": cleanUrl,
      "description": description,
      "orderCode": orderCode,
      "returnUrl": cleanUrl,
    };

    // Sắp xếp keys theo Alphabet: amount, cancelUrl, description, orderCode, returnUrl
    final sortedKeys = params.keys.toList()..sort();

    // 3. Tạo chuỗi ký data: key1=value1&key2=value2...
    final String signData = sortedKeys.map((key) {
      return '$key=${params[key]}';
    }).join('&');

    print("DEBUG signData: $signData");

    // 4. Ký HMAC-SHA256
    final hmac = Hmac(sha256, utf8.encode(checksumKey));
    final String signature = hmac.convert(utf8.encode(signData)).toString();

    // 5. Body gửi lên API
    final Map<String, dynamic> body = {
      ...params,
      "signature": signature,
    };

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/v2/payment-requests"),
        headers: {
          "Content-Type": "application/json",
          "x-client-id": clientId,
          "x-api-key": apiKey,
        },
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);
      if (result["code"] == "00") {
        return result["data"]["checkoutUrl"];
      } else {
        print("❌ PayOS Error: ${result["desc"]} (Mã lỗi: ${result["code"]})");
      }
    } catch (e) {
      print("❌ Connection Error: $e");
    }
    return null;
  }
}
