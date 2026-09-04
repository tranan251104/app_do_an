import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/navigator/model/promotion.dart';

abstract interface class PromotionRepository {
  Future<List<Promotion>> fetchPromotions();
}

/// Deterministic in-memory data source used by tests and offline previews.
class MockPromotionRepository implements PromotionRepository {
  final DateTime Function() _nowProvider;

  MockPromotionRepository({DateTime Function()? nowProvider})
    : _nowProvider = nowProvider ?? DateTime.now;

  static const List<int> _expiryOffsets = [7, 12, 18, 25, 35, 45, 60, 90];

  static const List<String> _brands = [
    'Đường sắt Việt Nam',
    'Traveloka',
    'LOTTE Mart',
    'CGV',
    'KFC',
    'Highlands Coffee',
    'Grab',
    'Shopee',
    'Lazada',
    'Tiki',
    'WinMart',
    'Garena',
    'Agoda',
    'Apple Store',
    'FPT Shop',
    'Canifa',
    'H&M',
    'Guardian',
    'Pharmacity',
    'Decathlon',
    'The Coffee House',
    'Green SM Food',
    'ShopeeFood',
    "Pizza 4P's",
    'Starbucks',
    'Burger King',
    'Sapporo Beer',
    'Xe khách Phương Trang',
    'Metro Hà Nội',
    'BeCar',
    'Netflix',
    'Thế Giới Di Động',
    'Điện Máy Xanh',
    'CellphoneS',
    'Uniqlo',
    'Zara',
    'Vinpearl',
    'Furama Resort Đà Nẵng',
    'Vietnam Airlines',
    'Bệnh viện Vinmec',
    'MEDIC Hòa Hảo',
    'California Fitness',
    'Coursera',
    'IELTS Fighter',
    'CG3D',
    'Con Cưng',
    'PetMart',
  ];

  @override
  Future<List<Promotion>> fetchPromotions() async {
    final now = _nowProvider();
    final today = DateTime(now.year, now.month, now.day);

    return _brands.indexed
        .map((entry) {
          final index = entry.$1;
          final brand = entry.$2;
          final expiryDate = today.add(
            Duration(days: _expiryOffsets[index % _expiryOffsets.length]),
          );

          return Promotion(
            id: 'mock-promotion-${index + 1}',
            iconKey: 'shopping_bag',
            brand: brand,
            description: 'Ưu đãi dành cho khách hàng AnPay',
            note: 'Dữ liệu dùng để kiểm thử',
            category: 'Khác',
            createdAt: today.subtract(Duration(days: index + 1)),
            validUntil: DateTime(
              expiryDate.year,
              expiryDate.month,
              expiryDate.day,
              23,
              59,
              59,
              999,
            ),
          );
        })
        .toList(growable: false);
  }
}

class BackendPromotionRepository implements PromotionRepository {
  @override
  Future<List<Promotion>> fetchPromotions() async {
    final rows = await AppServices.catalog.promotions();
    final now = DateTime.now();

    return rows.map((row) {
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
}
