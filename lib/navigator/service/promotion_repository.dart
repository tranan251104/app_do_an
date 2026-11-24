import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/config/app_config.dart';
import 'package:app_do_an/navigator/model/promotion.dart';
import 'package:flutter/foundation.dart';

abstract interface class PromotionRepository {
  Future<List<Promotion>> fetchPromotions();
}

/// Deterministic in-memory data source used by tests and offline previews.
class MockPromotionRepository implements PromotionRepository {
  final DateTime Function() _nowProvider;

  MockPromotionRepository({DateTime Function()? nowProvider})
    : _nowProvider = nowProvider ?? DateTime.now;

  static const _offerCount = 100;
  static const _offers = [
    ('Đường sắt Việt Nam', 'Di chuyển'),
    ('Traveloka', 'Du lịch'),
    ('LOTTE Mart', 'Mua sắm'),
    ('CGV', 'Giải trí'),
    ('KFC', 'Ăn uống'),
    ('Highlands Coffee', 'Ăn uống'),
    ('Grab', 'Di chuyển'),
    ('Shopee', 'Mua sắm'),
    ('Lazada', 'Mua sắm'),
    ('Tiki', 'Công nghệ'),
    ('WinMart', 'Mua sắm'),
    ('Garena', 'Giải trí'),
    ('Agoda', 'Du lịch'),
    ('Apple Store', 'Công nghệ'),
    ('FPT Shop', 'Công nghệ'),
    ('Canifa', 'Mua sắm'),
    ('H&M', 'Mua sắm'),
    ('Guardian', 'Sức khỏe'),
    ('Pharmacity', 'Sức khỏe'),
    ('Decathlon', 'Mua sắm'),
    ('The Coffee House', 'Ăn uống'),
    ('Green SM Food', 'Ăn uống'),
    ('ShopeeFood', 'Ăn uống'),
    ("Pizza 4P's", 'Ăn uống'),
    ('Starbucks', 'Ăn uống'),
    ('Burger King', 'Ăn uống'),
    ('Sapporo Beer', 'Ăn uống'),
    ('Xe khách Phương Trang', 'Di chuyển'),
    ('Metro Hà Nội', 'Di chuyển'),
    ('BeCar', 'Di chuyển'),
    ('Netflix', 'Giải trí'),
    ('Thế Giới Di Động', 'Công nghệ'),
    ('Điện Máy Xanh', 'Công nghệ'),
    ('CellphoneS', 'Công nghệ'),
    ('Uniqlo', 'Mua sắm'),
    ('Zara', 'Mua sắm'),
    ('Vinpearl', 'Du lịch'),
    ('Furama Resort Đà Nẵng', 'Du lịch'),
    ('Vietnam Airlines', 'Du lịch'),
    ('Bệnh viện Vinmec', 'Sức khỏe'),
    ('MEDIC Hòa Hảo', 'Sức khỏe'),
    ('California Fitness', 'Sức khỏe'),
    ('Coursera', 'Giáo dục'),
    ('IELTS Fighter', 'Giáo dục'),
    ('CG3D', 'Giáo dục'),
    ('Con Cưng', 'Mua sắm'),
    ('PetMart', 'Mua sắm'),
  ];

  @override
  Future<List<Promotion>> fetchPromotions() async {
    final now = _nowProvider();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(_offerCount, (index) {
      final (brand, category) = _offers[index % _offers.length];
      final benefit = DemoPromotionBenefit.values[index ~/ _offers.length];
      final expiryDay = (index * 11) % 31 + 1;
      return Promotion(
        id: 'mock-promotion-${index + 1}',
        iconKey: _iconKey(category),
        brand: brand,
        description: 'Ưu đãi giả lập · ${benefit.label}',
        note: 'Dữ liệu dùng để kiểm thử',
        category: category,
        createdAt: today.subtract(Duration(days: index + 1)),
        validUntil: _nextExpiry(now, expiryDay),
        demoBenefit: benefit,
      );
    }, growable: false);
  }

  DateTime _nextExpiry(DateTime now, int dayOfMonth) {
    final currentExpiry = _monthExpiry(now.year, now.month, dayOfMonth);
    if (!now.isAfter(currentExpiry)) return currentExpiry;
    return _monthExpiry(now.year, now.month + 1, dayOfMonth);
  }

  DateTime _monthExpiry(int year, int month, int dayOfMonth) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = dayOfMonth > lastDay ? lastDay : dayOfMonth;
    return DateTime(year, month, day, 23, 59, 59, 999, 999);
  }
}

class BackendPromotionRepository implements PromotionRepository {
  @override
  Future<List<Promotion>> fetchPromotions() async {
    final rows = await AppServices.catalog.promotions();
    final now = DateTime.now();

    final promotions = rows.map((row) {
      final category = row['category']?.toString() ?? 'Khác';
      final validFrom =
          DateTime.tryParse(row['validFrom']?.toString() ?? '')?.toLocal() ??
          now;
      final validUntil =
          DateTime.tryParse(row['validUntil']?.toString() ?? '')?.toLocal() ??
          now.add(const Duration(days: 30));

      return Promotion(
        id: row['id']?.toString() ?? row['code']?.toString() ?? '',
        iconKey: _iconKey(category),
        brand: row['title']?.toString() ?? 'Ưu đãi AnPay',
        description: row['description']?.toString() ?? '',
        note: 'Dữ liệu từ backend AnPay',
        category: category,
        createdAt: validFrom,
        validUntil: validUntil,
      );
    }).toList();

    const localHosts = {'10.0.2.2', 'localhost', '127.0.0.1', '::1'};
    final host = Uri.tryParse(AppConfig.apiBaseUrl)?.host;
    if (kDebugMode && localHosts.contains(host)) {
      promotions.addAll(await MockPromotionRepository().fetchPromotions());
    }
    return promotions;
  }
}

String _iconKey(String category) {
  final value = category.toLowerCase();
  if (value.contains('du lịch')) return 'flight';
  if (value.contains('di chuyển')) return 'car';
  if (value.contains('ăn')) return 'food';
  if (value.contains('công nghệ')) return 'devices';
  if (value.contains('giải trí')) return 'ticket';
  if (value.contains('sức khỏe')) return 'hospital';
  if (value.contains('giáo dục')) return 'school';
  return 'shopping_bag';
}
