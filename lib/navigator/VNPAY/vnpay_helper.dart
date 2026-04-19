import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

/// Hàm tạo URL thanh toán VNPay chuẩn version 2.1.0
String generateVNPayUrl({
  required String tmnCode,
  required String hashSecret,
  required int amount,
  required String returnUrl,
  bool isProduction = false,
}) {
  final DateTime now = DateTime.now();
  final String createDate = DateFormat('yyyyMMddHHmmss').format(now);
  
  // Thời gian hết hạn giao dịch (mặc định 15 phút)
  final String expireDate = DateFormat('yyyyMMddHHmmss').format(
    now.add(const Duration(minutes: 15)),
  );
  
  // Mã giao dịch duy nhất (TxnRef). 
  // Lưu ý: Trong thực tế nên dùng mã đơn hàng từ DB của bạn.
  final String txnRef = DateFormat('yyyyMMddHHmmss').format(now);

  final Map<String, String> params = {
    'vnp_Version': '2.1.0',
    'vnp_Command': 'pay',
    'vnp_TmnCode': tmnCode,
    'vnp_Amount': (amount * 100).toString(), // VNPay đơn vị là đồng * 100
    'vnp_CreateDate': createDate,
    'vnp_CurrCode': 'VND',
    'vnp_IpAddr': '127.0.0.1',
    'vnp_Locale': 'vn',
    'vnp_OrderInfo': 'Thanh toan nap tien vi',
    'vnp_OrderType': 'other',
    'vnp_ReturnUrl': returnUrl,
    'vnp_ExpireDate': expireDate,
    'vnp_TxnRef': txnRef,
  };

  // 1. Sắp xếp các tham số theo thứ tự alphabet (Quan trọng)
  final sortedKeys = params.keys.toList()..sort();

  // 2. Chuẩn hóa giá trị (URL Encode và thay '+' bằng '%20')
  String vnpEncode(String value) {
    return Uri.encodeQueryComponent(value).replaceAll('+', '%20');
  }

  // 3. Tạo chuỗi Hash Data (Dùng để băm) và Query String (Dùng để tạo URL)
  // Trong version 2.1.0, hai chuỗi này giống hệt nhau về nội dung các tham số
  final String queryString = sortedKeys.map((key) {
    return '$key=${vnpEncode(params[key]!)}';
  }).join('&');

  // 4. Ký HMAC-SHA512
  final hmac = Hmac(sha512, utf8.encode(hashSecret));
  final String secureHash = hmac.convert(utf8.encode(queryString)).toString();

  // 5. Chọn Base URL (Sandbox hoặc Production)
  final String baseUrl = isProduction
      ? 'https://pay.vnpayment.vn/paymentv2/vpcpay.html'
      : 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';

  // Trả về URL cuối cùng có kèm mã SecureHash
  return '$baseUrl?$queryString&vnp_SecureHash=$secureHash';
}
