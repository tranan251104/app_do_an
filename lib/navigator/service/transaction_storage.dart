import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_do_an/navigator/model/transaction.dart';

class TransactionStorage {
  static const String _key = "transactions";

  /// Lấy danh sách giao dịch
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((e) => Transaction.fromJson(jsonDecode(e))).toList();
  }

  /// Thêm giao dịch mới
  static Future<void> addTransaction(Transaction tx) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.insert(0, jsonEncode(tx.toJson())); // thêm vào đầu
    await prefs.setStringList(_key, data);
  }

  /// Xóa toàn bộ (nếu cần reset)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
