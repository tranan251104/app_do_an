import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/generic_package_screen.dart';

class TripModel {
  final String brand;
  final String time;
  final int price;
  final String type; // 'Giường nằm', 'Ghế ngồi', 'Eco'...
  final String from;
  final String to;

  TripModel({
    required this.brand,
    required this.time,
    required this.price,
    required this.type,
    required this.from,
    required this.to,
  });
}

class AppData {
  // 🔹 1. Cấu hình Hóa đơn (Bill)
  static final List<Map<String, dynamic>> billServices = [
    {
      "icon": Icons.lightbulb, "label": "Điện", "title": "Tiền điện",
      "inputLabel": "Mã khách hàng", "hint": "Ví dụ: PE01000123456", "type": "electric",
      "providers": ["EVN Hà Nội", "EVN TP.HCM", "EVN Miền Bắc", "EVN Miền Trung", "EVN Miền Nam"],
    },
    {
      "icon": Icons.water_drop, "label": "Nước", "title": "Tiền nước",
      "inputLabel": "Số danh bộ / Mã khách hàng", "hint": "Nhập mã trên hóa đơn nước", "type": "water",
      "providers": ["Sawaco TP.HCM", "Biwase Bình Dương", "Nước sạch Hà Nội", "Viwasupco", "DNP Water"],
    },
    {
      "icon": Icons.wifi, "label": "Internet", "title": "Internet",
      "inputLabel": "Mã khách hàng / Số hợp đồng", "hint": "Ví dụ: FTTH-123456", "type": "internet",
      "providers": ["FPT Telecom", "Viettel", "VNPT", "SCTV", "CMC Telecom", "NetNam"],
    },
    {
      "icon": Icons.tv, "label": "Truyền hình", "title": "Truyền hình",
      "inputLabel": "Mã khách hàng / Số thẻ", "hint": "Nhập mã trên hóa đơn truyền hình", "type": "tv",
      "providers": ["VTVcab", "K+", "FPT Play", "SCTV", "Viettel TV", "MyTV"],
    },
    {
      "icon": Icons.school, "label": "Học phí", "title": "Học phí",
      "inputLabel": "Mã học sinh / sinh viên", "hint": "Nhập mã số định danh tại trường", "type": "learning",
      "providers": ["SSC - Học phí trực tuyến", "Đại học Quốc gia", "SISap", "MISA CukCuk", "JETPAY"],
    },
    {
      "icon": Icons.phone, "label": "Điện thoại trả sau", "title": "Điện thoại trả sau",
      "inputLabel": "Số điện thoại", "hint": "Ví dụ: 0912345678", "type": "phone",
      "providers": ["Viettel", "MobiFone", "VinaPhone", "Vietnamobile"],
    },
    {
      "icon": Icons.home, "label": "Chung cư / Nhà ở", "title": "Tiền nhà trọ",
      "inputLabel": "Mã phòng / Mã hợp đồng", "hint": "Nhập mã quản lý phòng trọ của bạn", "type": "home",
      "providers": ["Chung cư mini", "Nhà trọ liên kết AnPay", "Ký túc xá", "Vinhomes", "Novaland"],
    },
    {
      "icon": Icons.security, "label": "Bảo hiểm", "title": "Phí bảo hiểm",
      "inputLabel": "Số hợp đồng bảo hiểm", "hint": "Nhập mã hợp đồng", "type": "insurance",
      "providers": ["Prudential", "Manulife", "AIA", "Dai-ichi Life", "Bảo Việt"],
    },
    {
      "icon": Icons.local_gas_station, "label": "Phí môi trường", "title": "Phí rác thải",
      "inputLabel": "Mã khách hàng", "hint": "Nhập mã định danh hộ gia đình", "type": "waste",
      "providers": ["Môi trường đô thị Hà Nội", "Citenco TP.HCM", "Môi trường Đà Nẵng"],
    },
  ];

  // 🔹 2. Cấu hình Viễn thông (Telecom Packages)
  static final List<PackageModel> dataPackages = [
    PackageModel(name: "ST5K", price: 5000, description: "500MB sử dụng đến 24h"),
    PackageModel(name: "ST10K", price: 10000, description: "2GB sử dụng trong 24h"),
    PackageModel(name: "ST15K", price: 15000, description: "3GB sử dụng trong 3 ngày"),
    PackageModel(name: "ST30K", price: 30000, description: "7GB sử dụng trong 7 ngày"),
    PackageModel(name: "V90", price: 90000, description: "2GB/ngày + Miễn phí nội mạng"),
    PackageModel(name: "V120", price: 120000, description: "2GB/ngày + Miễn phí nội, ngoại mạng"),
    PackageModel(name: "ST70", price: 70000, description: "3GB/tháng, hết tốc độ cao dừng truy cập"),
    PackageModel(name: "MIMAX90", price: 90000, description: "5GB/tháng, hết tốc độ cao miễn phí 256kbps"),
  ];

  static final List<PackageModel> musicPackages = [
    PackageModel(name: "IMUZIK_MONTH", price: 10000, description: "Phí thuê bao tháng Viettel"),
    PackageModel(name: "FUNRING_MONTH", price: 9000, description: "Phí thuê bao tháng MobiFone"),
    PackageModel(name: "RINGTUNES_MONTH", price: 9000, description: "Phí thuê bao tháng VinaPhone"),
    PackageModel(name: "SONG_DL", price: 5000, description: "Tải bài hát làm nhạc chờ"),
  ];

  static final List<PackageModel> tvPackages = [
    PackageModel(name: "VIP_1_MONTH", price: 66000, description: "Gói VIP 1 tháng FPT Play"),
    PackageModel(name: "SPORT_MONTH", price: 150000, description: "Gói Thể thao tháng"),
    PackageModel(name: "K+_PREMIUM", price: 175000, description: "Trọn gói K+ trên App"),
    PackageModel(name: "VIEON_ALL_ACCESS", price: 199000, description: "Trọn bộ nội dung VieON"),
  ];

  // 🔹 3. Cấu hình Thẻ (Cards) - Phone & Game
  static final List<Map<String, dynamic>> phoneCards = [
    {"brand": "Viettel", "discount": "2.5%"},
    {"brand": "MobiFone", "discount": "3.0%"},
    {"brand": "VinaPhone", "discount": "3.0%"},
    {"brand": "Vietnamobile", "discount": "5.0%"},
    {"brand": "Gmobile", "discount": "4.0%"},
  ];

  static final List<Map<String, dynamic>> gameCards = [
    {"brand": "Garena", "discount": "1.5%"},
    {"brand": "Zing Card", "discount": "2.0%"},
    {"brand": "VTC Coin", "discount": "3.0%"},
    {"brand": "Gate", "discount": "4.0%"},
    {"brand": "Appota", "discount": "5.0%"},
    {"brand": "Funcard", "discount": "3.0%"},
    {"brand": "SohaCoin", "discount": "2.5%"},
  ];

  // 🔹 4. Cấu hình Đi lại (Travel) - Sinh 50+ chuyến mẫu cho BẤT KỲ TUYẾN ĐƯỜNG NÀO
  static List<TripModel> getMockTrips(String serviceType, String from, String to) {
    List<TripModel> trips = [];
    final fromNorm = from.trim();
    final toNorm = to.trim();

    if (serviceType == 'bus') {
      final busBrands = ["Phương Trang", "Thành Bưởi", "Hải Âu", "Hoàng Long", "Kumho Samco", "Văn Minh", "Sao Việt", "VietBus", "Mai Linh"];
      for (int i = 0; i < 50; i++) {
        trips.add(TripModel(
          brand: busBrands[i % busBrands.length],
          time: "${(i % 24).toString().padLeft(2, '0')}:${(i % 2 == 0) ? '00' : '30'} - ${((i + 6) % 24).toString().padLeft(2, '0')}:30",
          price: 180000 + (i * 2000),
          type: i % 5 == 0 ? "Limousine VIP" : "Giường nằm 36 chỗ",
          from: fromNorm,
          to: toNorm,
        ));
      }
    } else if (serviceType == 'train') {
      for (int i = 1; i <= 40; i++) {
        trips.add(TripModel(
          brand: "Đường Sắt Việt Nam (Tàu SE$i/TN$i)",
          time: "${(i % 24).toString().padLeft(2, '0')}:15 - ${((i + 14) % 24).toString().padLeft(2, '0')}:45",
          price: 350000 + (i * 10000),
          type: i % 3 == 0 ? "Khoang 4 điều hòa" : "Ghế mềm điều hòa",
          from: fromNorm,
          to: toNorm,
        ));
      }
    } else if (serviceType == 'plane') {
      final airlines = ["Vietnam Airlines", "Vietjet Air", "Bamboo Airways", "Vietravel Airlines"];
      for (int i = 0; i < 40; i++) {
        trips.add(TripModel(
          brand: airlines[i % airlines.length],
          time: "${(i % 24).toString().padLeft(2, '0')}:00 - ${((i + 2) % 24).toString().padLeft(2, '0')}:10",
          price: 850000 + (i * 40000),
          type: i % 10 == 0 ? "Business Class" : "Economy Class",
          from: fromNorm,
          to: toNorm,
        ));
      }
    } else {
      for (int i = 0; i < 20; i++) {
        trips.add(TripModel(
          brand: i % 2 == 0 ? "Grab" : "Xanh SM",
          time: "Ưu tiên đón ngay",
          price: 25000 + (i * 10000),
          type: i % 3 == 0 ? "Xe điện 5 chỗ" : "Xe xăng 4 chỗ",
          from: fromNorm,
          to: toNorm,
        ));
      }
    }
    return trips;
  }

  // 🔹 5. Cấu hình Đối tác liên kết (Partners)
  static final List<Map<String, dynamic>> partners = [
    {"icon": Icons.local_taxi, "label": "Grab", "url": "https://www.grab.com/vn/"},
    {"icon": Icons.local_taxi, "label": "Be", "url": "https://be.com.vn/"},
    {"icon": Icons.movie, "label": "CGV", "url": "https://www.cgv.vn/"},
    {"icon": Icons.theaters, "label": "Galaxy Cinema", "url": "https://www.galaxycine.vn/"},
    {"icon": Icons.theaters, "label": "Lotte Cinema", "url": "https://www.lottecinemavn.com/"},
    {"icon": Icons.videogame_asset, "label": "Garena", "url": "https://napthe.vn/"},
    {"icon": Icons.tv, "label": "FPT Play", "url": "https://fptplay.vn/"},
    {"icon": Icons.shopping_bag, "label": "Shopee", "url": "https://shopee.vn/"},
    {"icon": Icons.shopping_cart, "label": "Lazada", "url": "https://www.lazada.vn/"},
    {"icon": Icons.restaurant, "label": "Baemin", "url": "https://baemin.vn/"},
    {"icon": Icons.delivery_dining, "label": "ShopeeFood", "url": "https://shopeefood.vn/"},
    {"icon": Icons.travel_explore, "label": "Traveloka", "url": "https://www.traveloka.com/vi-vn/"},
    {"icon": Icons.hotel, "label": "Agoda", "url": "https://www.agoda.com/vi-vn/"},
  ];
}
