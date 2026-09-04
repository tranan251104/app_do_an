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
      "icon": Icons.lightbulb,
      "label": "Điện",
      "title": "Tiền điện",
      "inputLabel": "Mã khách hàng",
      "hint": "Ví dụ: PE01000123456",
      "type": "electric",
      "providers": [
        "EVN Hà Nội",
        "EVN TP.HCM",
        "EVN Miền Bắc",
        "EVN Miền Trung",
        "EVN Miền Nam",
      ],
    },
    {
      "icon": Icons.water_drop,
      "label": "Nước",
      "title": "Tiền nước",
      "inputLabel": "Số danh bộ / Mã khách hàng",
      "hint": "Nhập mã trên hóa đơn nước",
      "type": "water",
      "providers": [
        "Sawaco TP.HCM",
        "Biwase Bình Dương",
        "Nước sạch Hà Nội",
        "Viwasupco",
        "DNP Water",
      ],
    },
    {
      "icon": Icons.wifi,
      "label": "Internet",
      "title": "Internet",
      "inputLabel": "Mã khách hàng / Số hợp đồng",
      "hint": "Ví dụ: FTTH-123456",
      "type": "internet",
      "providers": [
        "FPT Telecom",
        "Viettel",
        "VNPT",
        "SCTV",
        "CMC Telecom",
        "NetNam",
      ],
    },
    {
      "icon": Icons.tv,
      "label": "Truyền hình",
      "title": "Truyền hình",
      "inputLabel": "Mã khách hàng / Số thẻ",
      "hint": "Nhập mã trên hóa đơn truyền hình",
      "type": "tv",
      "providers": ["VTVcab", "K+", "FPT Play", "SCTV", "Viettel TV", "MyTV"],
    },
    {
      "icon": Icons.school,
      "label": "Học phí",
      "title": "Học phí",
      "inputLabel": "Mã học sinh / sinh viên",
      "hint": "Nhập mã số định danh tại trường",
      "type": "learning",
      "providers": [
        "SSC - Học phí trực tuyến",
        "Đại học Quốc gia",
        "SISap",
        "MISA CukCuk",
        "JETPAY",
      ],
    },
    {
      "icon": Icons.phone,
      "label": "Điện thoại trả sau",
      "title": "Điện thoại trả sau",
      "inputLabel": "Số điện thoại",
      "hint": "Ví dụ: 0912345678",
      "type": "phone",
      "providers": ["Viettel", "MobiFone", "VinaPhone", "Vietnamobile"],
    },
    {
      "icon": Icons.home,
      "label": "Chung cư / Nhà ở",
      "title": "Tiền nhà trọ",
      "inputLabel": "Mã phòng / Mã hợp đồng",
      "hint": "Nhập mã quản lý phòng trọ của bạn",
      "type": "home",
      "providers": [
        "Chung cư mini",
        "Nhà trọ liên kết AnPay",
        "Ký túc xá",
        "Vinhomes",
        "Novaland",
      ],
    },
    {
      "icon": Icons.security,
      "label": "Bảo hiểm",
      "title": "Phí bảo hiểm",
      "inputLabel": "Số hợp đồng bảo hiểm",
      "hint": "Nhập mã hợp đồng",
      "type": "insurance",
      "providers": [
        "Prudential",
        "Manulife",
        "AIA",
        "Dai-ichi Life",
        "Bảo Việt",
      ],
    },
    {
      "icon": Icons.local_gas_station,
      "label": "Phí môi trường",
      "title": "Phí rác thải",
      "inputLabel": "Mã khách hàng",
      "hint": "Nhập mã định danh hộ gia đình",
      "type": "waste",
      "providers": [
        "Môi trường đô thị Hà Nội",
        "Citenco TP.HCM",
        "Môi trường Đà Nẵng",
      ],
    },
  ];

  // 🔹 2. Cấu hình Viễn thông (dữ liệu demo, 20 gói/nhà cung cấp)
  static final Map<String, List<PackageModel>> dataPackagesByProvider = {
    "Viettel": _buildDataPackages("Viettel", "VT"),
    "MobiFone": _buildDataPackages("MobiFone", "MB"),
    "VinaPhone": _buildDataPackages("VinaPhone", "VN"),
  };

  static final Map<String, List<PackageModel>> musicPackagesByProvider = {
    "Viettel iMuzik": _buildMusicPackages("Viettel iMuzik", "IM"),
    "MobiFone FunRing": _buildMusicPackages("MobiFone FunRing", "FR"),
  };

  static final Map<String, List<PackageModel>> tvPackagesByProvider = {
    "FPT Play": _buildStreamingPackages("FPT Play", "FPT", 66000),
    "K+": _buildStreamingPackages("K+", "KPLUS", 175000),
    "VieON": _buildStreamingPackages("VieON", "VIEON", 69000),
  };

  static final Map<String, List<PackageModel>> roamingPackagesByProvider = {
    "Viettel": _buildRoamingPackages("Viettel", "VTIR"),
    "VinaPhone": _buildRoamingPackages("VinaPhone", "VNIR"),
  };

  static final Map<String, List<PackageModel>> partnerPackagesByProvider = {
    "Garena": _buildGarenaPackages(),
    "CGV": _buildCinemaPackages("CGV", "CGV", 90000),
    "Galaxy": _buildCinemaPackages("Galaxy", "GALAXY", 80000),
    "SPX": _buildSpxPackages(),
    "FPT Play": tvPackagesByProvider["FPT Play"]!,
    "Ticketbox": _buildTicketboxPackages(),
    "VieON": tvPackagesByProvider["VieON"]!,
  };

  static const Map<String, String> partnerItemLabels = {
    "Garena": "Chọn gói nạp game",
    "CGV": "Chọn vé hoặc combo",
    "Galaxy": "Chọn vé hoặc combo",
    "SPX": "Chọn dịch vụ giao hàng",
    "FPT Play": "Chọn gói FPT Play",
    "Ticketbox": "Chọn loại vé sự kiện",
    "VieON": "Chọn gói VieON",
  };

  static List<PackageModel> get fptPlayPackages =>
      tvPackagesByProvider["FPT Play"]!;

  static List<PackageModel> _buildDataPackages(
    String provider,
    String codePrefix,
  ) {
    const specs = <(String, String, int, String)>[
      ("DAY1", "Data ngày 1GB", 5000, "1GB tốc độ cao, dùng trong 24 giờ"),
      ("DAY3", "Data ngày 3GB", 10000, "3GB tốc độ cao, dùng trong 24 giờ"),
      ("D3", "Data 3 ngày", 15000, "5GB tốc độ cao trong 3 ngày"),
      ("W7", "Data tuần 7GB", 30000, "7GB tốc độ cao trong 7 ngày"),
      ("W15", "Data tuần 15GB", 50000, "15GB tốc độ cao trong 7 ngày"),
      ("M6", "Tháng cơ bản 6GB", 70000, "6GB tốc độ cao trong 30 ngày"),
      ("M10", "Tháng tiêu chuẩn 10GB", 90000, "10GB trong 30 ngày"),
      ("M2D", "Tháng 2GB/ngày", 120000, "2GB mỗi ngày trong 30 ngày"),
      ("M3D", "Tháng 3GB/ngày", 150000, "3GB mỗi ngày trong 30 ngày"),
      ("M4D", "Tháng 4GB/ngày", 180000, "4GB mỗi ngày trong 30 ngày"),
      ("SOCIAL", "Mạng xã hội", 30000, "Ưu đãi data Facebook, TikTok và Zalo"),
      (
        "VIDEO",
        "Video không giới hạn",
        50000,
        "Ưu đãi data YouTube và nền tảng video",
      ),
      (
        "GAME",
        "Game tốc độ cao",
        40000,
        "Data ưu tiên cho các trò chơi phổ biến",
      ),
      (
        "STUDY",
        "Học tập trực tuyến",
        45000,
        "Data cho Zoom, Meet và nền tảng học tập",
      ),
      (
        "WORK",
        "Làm việc linh hoạt",
        80000,
        "20GB data kèm ưu đãi họp trực tuyến",
      ),
      ("NIGHT", "Data ban đêm", 20000, "20GB sử dụng từ 0h đến 6h"),
      ("FAMILY", "Data gia đình", 200000, "60GB chia sẻ cho tối đa 4 thuê bao"),
      ("Y_BASIC", "Năm tiết kiệm", 600000, "8GB mỗi tháng trong 12 tháng"),
      ("Y_PLUS", "Năm nâng cao", 900000, "15GB mỗi tháng trong 12 tháng"),
      (
        "Y_MAX",
        "Năm không giới hạn",
        1200000,
        "Data dung lượng cao trong 12 tháng",
      ),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "${codePrefix}_${spec.$1}",
            name: "$provider ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildMusicPackages(
    String provider,
    String codePrefix,
  ) {
    const specs = <(String, String, int, String)>[
      ("BASIC_M", "Cơ bản 1 tháng", 9000, "Cài và đổi nhạc chờ cơ bản"),
      (
        "PLUS_M",
        "Nâng cao 1 tháng",
        15000,
        "Kho nhạc mở rộng, đổi bài không giới hạn",
      ),
      (
        "BASIC_3M",
        "Cơ bản 3 tháng",
        25000,
        "Tiết kiệm phí thuê bao trong 3 tháng",
      ),
      (
        "BASIC_6M",
        "Cơ bản 6 tháng",
        45000,
        "Tiết kiệm phí thuê bao trong 6 tháng",
      ),
      ("BASIC_12M", "Cơ bản 12 tháng", 85000, "Sử dụng dịch vụ trong 12 tháng"),
      ("SONG_1", "Tải 1 bài hát", 3000, "Chọn một bài làm nhạc chờ"),
      ("SONG_5", "Bộ 5 bài hát", 12000, "Luân phiên 5 bài nhạc chờ"),
      ("SONG_10", "Bộ 10 bài hát", 20000, "Luân phiên 10 bài nhạc chờ"),
      ("VPOP", "Tuyển tập V-Pop", 18000, "Những ca khúc V-Pop nổi bật"),
      ("KPOP", "Tuyển tập K-Pop", 18000, "Những ca khúc K-Pop thịnh hành"),
      ("BOLERO", "Tuyển tập Bolero", 15000, "Kho nhạc Bolero chọn lọc"),
      ("ACOUSTIC", "Tuyển tập Acoustic", 15000, "Giai điệu Acoustic nhẹ nhàng"),
      ("EDM", "Tuyển tập EDM", 18000, "Nhạc điện tử và remix sôi động"),
      ("LOVE", "Nhạc chờ tình yêu", 12000, "Bộ sưu tập ca khúc tình yêu"),
      (
        "KIDS",
        "Nhạc chờ thiếu nhi",
        12000,
        "Ca khúc vui nhộn dành cho gia đình",
      ),
      (
        "BUSINESS",
        "Nhạc chờ doanh nghiệp",
        50000,
        "Lời chào và giới thiệu doanh nghiệp",
      ),
      ("PERSONAL", "Lời chào cá nhân", 30000, "Thu âm lời chào nhạc chờ riêng"),
      (
        "FAMILY",
        "Nhóm gia đình",
        35000,
        "Dùng chung bộ sưu tập cho 4 thuê bao",
      ),
      ("HOLIDAY", "Nhạc chờ lễ hội", 10000, "Bộ sưu tập theo mùa và ngày lễ"),
      (
        "PREMIUM",
        "Không quảng cáo",
        25000,
        "Kho nhạc cao cấp, không nội dung quảng cáo",
      ),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "${codePrefix}_${spec.$1}",
            name: "$provider ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildStreamingPackages(
    String provider,
    String codePrefix,
    int basePrice,
  ) {
    final specs = <(String, String, int, String)>[
      (
        "MOBILE_DAY",
        "Mobile 1 ngày",
        10000,
        "Xem trên điện thoại trong 24 giờ",
      ),
      (
        "MOBILE_WEEK",
        "Mobile 7 ngày",
        29000,
        "Xem trên điện thoại trong 7 ngày",
      ),
      (
        "BASIC_1M",
        "Cơ bản 1 tháng",
        basePrice,
        "Nội dung cơ bản trên 1 thiết bị",
      ),
      (
        "VIP_1M",
        "VIP 1 tháng",
        basePrice + 20000,
        "Kho phim VIP trên 2 thiết bị",
      ),
      (
        "FAMILY_1M",
        "Gia đình 1 tháng",
        basePrice + 40000,
        "Xem đồng thời trên 4 thiết bị",
      ),
      (
        "SPORT_1M",
        "Thể thao 1 tháng",
        basePrice + 85000,
        "Các kênh và giải đấu thể thao",
      ),
      (
        "KIDS_1M",
        "Thiếu nhi 1 tháng",
        _roundPrice(basePrice * 3 ~/ 4),
        "Nội dung an toàn dành cho trẻ em",
      ),
      (
        "MOVIE_1M",
        "Phim điện ảnh 1 tháng",
        basePrice + 30000,
        "Kho phim điện ảnh chọn lọc",
      ),
      (
        "ASIA_1M",
        "Phim châu Á 1 tháng",
        basePrice + 15000,
        "Phim Việt, Hàn Quốc, Trung Quốc và Thái Lan",
      ),
      (
        "WORLD_1M",
        "Quốc tế 1 tháng",
        basePrice + 45000,
        "Phim và chương trình quốc tế",
      ),
      (
        "BASIC_3M",
        "Cơ bản 3 tháng",
        _roundPrice(basePrice * 3 - 10000),
        "Gói cơ bản tiết kiệm trong 3 tháng",
      ),
      (
        "VIP_3M",
        "VIP 3 tháng",
        _roundPrice((basePrice + 20000) * 3 - 15000),
        "Gói VIP tiết kiệm trong 3 tháng",
      ),
      (
        "FAMILY_3M",
        "Gia đình 3 tháng",
        _roundPrice((basePrice + 40000) * 3 - 20000),
        "Gói gia đình trong 3 tháng",
      ),
      (
        "SPORT_3M",
        "Thể thao 3 tháng",
        _roundPrice((basePrice + 85000) * 3 - 30000),
        "Gói thể thao trong 3 tháng",
      ),
      (
        "BASIC_6M",
        "Cơ bản 6 tháng",
        _roundPrice(basePrice * 6 - 40000),
        "Gói cơ bản tiết kiệm trong 6 tháng",
      ),
      (
        "VIP_6M",
        "VIP 6 tháng",
        _roundPrice((basePrice + 20000) * 6 - 60000),
        "Gói VIP tiết kiệm trong 6 tháng",
      ),
      (
        "BASIC_12M",
        "Cơ bản 12 tháng",
        _roundPrice(basePrice * 12 - 100000),
        "Gói cơ bản trọn năm",
      ),
      (
        "VIP_12M",
        "VIP 12 tháng",
        _roundPrice((basePrice + 20000) * 12 - 150000),
        "Gói VIP trọn năm",
      ),
      (
        "ALL_6M",
        "Toàn bộ nội dung 6 tháng",
        _roundPrice((basePrice + 120000) * 6 - 100000),
        "Phim, truyền hình và thể thao trong 6 tháng",
      ),
      (
        "ALL_12M",
        "Toàn bộ nội dung 12 tháng",
        _roundPrice((basePrice + 120000) * 12 - 250000),
        "Trọn bộ nội dung trong 12 tháng",
      ),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "${codePrefix}_${spec.$1}",
            name: "$provider ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildRoamingPackages(
    String provider,
    String codePrefix,
  ) {
    const specs = <(String, String, int, String)>[
      ("TH_D1", "Thái Lan 1 ngày", 50000, "1GB data roaming tại Thái Lan"),
      ("TH_D3", "Thái Lan 3 ngày", 120000, "4GB data roaming tại Thái Lan"),
      ("SG_D1", "Singapore 1 ngày", 60000, "1GB data roaming tại Singapore"),
      ("SG_D5", "Singapore 5 ngày", 220000, "8GB data roaming tại Singapore"),
      ("SEA_D3", "Đông Nam Á 3 ngày", 150000, "5GB tại các nước Đông Nam Á"),
      ("SEA_D7", "Đông Nam Á 7 ngày", 300000, "12GB tại các nước Đông Nam Á"),
      ("JP_D3", "Nhật Bản 3 ngày", 200000, "4GB data roaming tại Nhật Bản"),
      ("JP_D7", "Nhật Bản 7 ngày", 380000, "10GB data roaming tại Nhật Bản"),
      ("KR_D3", "Hàn Quốc 3 ngày", 180000, "4GB data roaming tại Hàn Quốc"),
      ("KR_D7", "Hàn Quốc 7 ngày", 350000, "10GB data roaming tại Hàn Quốc"),
      ("CN_D5", "Trung Quốc 5 ngày", 280000, "8GB data roaming tại Trung Quốc"),
      ("HK_D5", "Hong Kong 5 ngày", 260000, "8GB data roaming tại Hong Kong"),
      ("TW_D5", "Đài Loan 5 ngày", 260000, "8GB data roaming tại Đài Loan"),
      ("AU_D7", "Úc 7 ngày", 450000, "10GB data roaming tại Úc"),
      ("EU_D7", "Châu Âu 7 ngày", 550000, "10GB tại các nước Châu Âu"),
      ("EU_D15", "Châu Âu 15 ngày", 900000, "25GB tại các nước Châu Âu"),
      ("US_D7", "Mỹ 7 ngày", 600000, "10GB data roaming tại Mỹ"),
      ("US_D15", "Mỹ 15 ngày", 950000, "25GB data roaming tại Mỹ"),
      ("GLOBAL_D10", "Toàn cầu 10 ngày", 1200000, "20GB tại hơn 60 quốc gia"),
      ("GLOBAL_D30", "Toàn cầu 30 ngày", 2500000, "60GB tại hơn 60 quốc gia"),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "${codePrefix}_${spec.$1}",
            name: "$provider ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildGarenaPackages() {
    const specs = <(String, String, int, String)>[
      (
        "FF_10",
        "Free Fire 20 kim cương",
        10000,
        "Nạp trực tiếp theo ID người chơi",
      ),
      (
        "FF_20",
        "Free Fire 45 kim cương",
        20000,
        "Nạp trực tiếp theo ID người chơi",
      ),
      (
        "FF_50",
        "Free Fire 110 kim cương",
        50000,
        "Nạp trực tiếp theo ID người chơi",
      ),
      (
        "FF_100",
        "Free Fire 230 kim cương",
        100000,
        "Nạp trực tiếp theo ID người chơi",
      ),
      (
        "LQ_10",
        "Liên Quân 20 quân huy",
        10000,
        "Nạp quân huy theo tài khoản Garena",
      ),
      (
        "LQ_20",
        "Liên Quân 40 quân huy",
        20000,
        "Nạp quân huy theo tài khoản Garena",
      ),
      (
        "LQ_50",
        "Liên Quân 105 quân huy",
        50000,
        "Nạp quân huy theo tài khoản Garena",
      ),
      (
        "LQ_100",
        "Liên Quân 210 quân huy",
        100000,
        "Nạp quân huy theo tài khoản Garena",
      ),
      (
        "FCM_20",
        "FC Mobile 40 FC Point",
        20000,
        "Nạp FC Point theo UID người chơi",
      ),
      (
        "FCM_50",
        "FC Mobile 105 FC Point",
        50000,
        "Nạp FC Point theo UID người chơi",
      ),
      (
        "FCM_100",
        "FC Mobile 220 FC Point",
        100000,
        "Nạp FC Point theo UID người chơi",
      ),
      (
        "FCM_200",
        "FC Mobile 460 FC Point",
        200000,
        "Nạp FC Point theo UID người chơi",
      ),
      (
        "DF_20",
        "Delta Force 100 Delta Coin",
        20000,
        "Nạp Delta Coin theo UID người chơi",
      ),
      (
        "DF_50",
        "Delta Force 260 Delta Coin",
        50000,
        "Nạp Delta Coin theo UID người chơi",
      ),
      (
        "DF_100",
        "Delta Force 530 Delta Coin",
        100000,
        "Nạp Delta Coin theo UID người chơi",
      ),
      (
        "DF_200",
        "Delta Force 1080 Delta Coin",
        200000,
        "Nạp Delta Coin theo UID người chơi",
      ),
      ("SHELL_50", "50.000 Sò Garena", 50000, "Nạp vào ví Sò Garena"),
      ("SHELL_100", "100.000 Sò Garena", 100000, "Nạp vào ví Sò Garena"),
      ("SHELL_200", "200.000 Sò Garena", 200000, "Nạp vào ví Sò Garena"),
      ("SHELL_500", "500.000 Sò Garena", 500000, "Nạp vào ví Sò Garena"),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "GARENA_${spec.$1}",
            name: spec.$2,
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildCinemaPackages(
    String provider,
    String codePrefix,
    int baseTicketPrice,
  ) {
    final specs = <(String, String, int, String)>[
      (
        "2D_WEEKDAY",
        "Vé 2D ngày thường",
        baseTicketPrice,
        "Một vé ghế tiêu chuẩn từ thứ 2 đến thứ 5",
      ),
      (
        "2D_WEEKEND",
        "Vé 2D cuối tuần",
        baseTicketPrice + 20000,
        "Một vé ghế tiêu chuẩn từ thứ 6 đến chủ nhật",
      ),
      (
        "STUDENT",
        "Vé học sinh, sinh viên",
        baseTicketPrice - 20000,
        "Xuất trình thẻ học sinh hoặc sinh viên khi nhận vé",
      ),
      (
        "CHILD",
        "Vé trẻ em",
        baseTicketPrice - 15000,
        "Dành cho trẻ em theo quy định của rạp",
      ),
      (
        "COUPLE",
        "Cặp vé 2D",
        baseTicketPrice * 2 - 10000,
        "Hai vé 2D ghế tiêu chuẩn",
      ),
      ("3D", "Vé phim 3D", baseTicketPrice + 40000, "Một vé 3D ghế tiêu chuẩn"),
      ("IMAX", "Vé IMAX", baseTicketPrice + 70000, "Một vé phòng chiếu IMAX"),
      (
        "4DX",
        "Vé 4DX",
        baseTicketPrice + 100000,
        "Một vé phòng chiếu chuyển động 4DX",
      ),
      (
        "GOLD",
        "Vé Gold Class",
        baseTicketPrice + 200000,
        "Một vé phòng chiếu cao cấp",
      ),
      (
        "SWEETBOX",
        "Cặp ghế Sweetbox",
        baseTicketPrice * 2 + 30000,
        "Hai vé ghế đôi Sweetbox",
      ),
      (
        "COMBO_SINGLE",
        "Vé và combo cá nhân",
        baseTicketPrice + 60000,
        "Một vé 2D, một bắp và một nước",
      ),
      (
        "COMBO_COUPLE",
        "Cặp vé và combo đôi",
        baseTicketPrice * 2 + 100000,
        "Hai vé 2D, một bắp lớn và hai nước",
      ),
      (
        "FAMILY",
        "Combo gia đình",
        baseTicketPrice * 3 - 20000,
        "Hai vé người lớn và một vé trẻ em",
      ),
      (
        "VOUCHER_5",
        "Bộ 5 voucher ngày thường",
        baseTicketPrice * 5 - 50000,
        "Năm voucher vé 2D ngày thường",
      ),
      (
        "VOUCHER_10",
        "Bộ 10 voucher ngày thường",
        baseTicketPrice * 10 - 120000,
        "Mười voucher vé 2D ngày thường",
      ),
      (
        "GIFT_100",
        "Thẻ quà tặng 100K",
        100000,
        "Dùng để thanh toán vé và đồ ăn tại rạp",
      ),
      (
        "GIFT_200",
        "Thẻ quà tặng 200K",
        200000,
        "Dùng để thanh toán vé và đồ ăn tại rạp",
      ),
      (
        "GIFT_500",
        "Thẻ quà tặng 500K",
        500000,
        "Dùng để thanh toán vé và đồ ăn tại rạp",
      ),
      (
        "MOVIE_PASS",
        "Thẻ xem 10 phim",
        baseTicketPrice * 9,
        "Quyền đổi tối đa 10 vé 2D tiêu chuẩn",
      ),
      (
        "PREMIUM_COUPLE",
        "Combo đôi cao cấp",
        baseTicketPrice * 2 + 180000,
        "Hai vé cao cấp kèm bắp và nước",
      ),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "${codePrefix}_${spec.$1}",
            name: "$provider ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildSpxPackages() {
    const specs = <(String, String, int, String)>[
      ("CITY_05", "Nội thành đến 0,5kg", 18000, "Giao tiêu chuẩn nội thành"),
      ("CITY_1", "Nội thành đến 1kg", 22000, "Giao tiêu chuẩn nội thành"),
      ("CITY_2", "Nội thành đến 2kg", 28000, "Giao tiêu chuẩn nội thành"),
      (
        "CITY_FAST",
        "Nội thành hỏa tốc",
        45000,
        "Ưu tiên giao nhanh trong ngày",
      ),
      (
        "PROVINCE_05",
        "Nội tỉnh đến 0,5kg",
        20000,
        "Giao tiêu chuẩn trong tỉnh",
      ),
      ("PROVINCE_1", "Nội tỉnh đến 1kg", 26000, "Giao tiêu chuẩn trong tỉnh"),
      ("PROVINCE_2", "Nội tỉnh đến 2kg", 34000, "Giao tiêu chuẩn trong tỉnh"),
      (
        "REGION_05",
        "Nội miền đến 0,5kg",
        28000,
        "Giao giữa các tỉnh cùng miền",
      ),
      ("REGION_1", "Nội miền đến 1kg", 35000, "Giao giữa các tỉnh cùng miền"),
      ("REGION_2", "Nội miền đến 2kg", 45000, "Giao giữa các tỉnh cùng miền"),
      ("NATION_05", "Liên miền đến 0,5kg", 35000, "Giao tiêu chuẩn liên miền"),
      ("NATION_1", "Liên miền đến 1kg", 45000, "Giao tiêu chuẩn liên miền"),
      ("NATION_2", "Liên miền đến 2kg", 60000, "Giao tiêu chuẩn liên miền"),
      (
        "ECONOMY",
        "Giao tiết kiệm",
        16000,
        "Thời gian giao linh hoạt với chi phí thấp",
      ),
      ("EXPRESS", "Giao nhanh toàn quốc", 75000, "Ưu tiên xử lý và vận chuyển"),
      (
        "COD_1",
        "Giao hàng COD cơ bản",
        25000,
        "Thu hộ đơn hàng tối đa 1 triệu đồng",
      ),
      (
        "COD_5",
        "Giao hàng COD nâng cao",
        45000,
        "Thu hộ đơn hàng tối đa 5 triệu đồng",
      ),
      (
        "HIGH_VALUE",
        "Bưu gửi giá trị cao",
        120000,
        "Tăng cường kiểm soát cho hàng giá trị cao",
      ),
      (
        "RETURN",
        "Gói giao và hoàn hàng",
        50000,
        "Bao gồm một lượt giao và một lượt hoàn",
      ),
      (
        "BUSINESS",
        "Gói doanh nghiệp 20 đơn",
        350000,
        "Hai mươi lượt giao nội thành tiêu chuẩn",
      ),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "SPX_${spec.$1}",
            name: "SPX ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static List<PackageModel> _buildTicketboxPackages() {
    const specs = <(String, String, int, String)>[
      ("MUSIC_STD", "Đêm nhạc - Standard", 250000, "Vé khu vực tiêu chuẩn"),
      ("MUSIC_VIP", "Đêm nhạc - VIP", 750000, "Vé khu vực VIP và quà tặng"),
      ("CONCERT_STD", "Concert - Standard", 500000, "Vé khu vực tiêu chuẩn"),
      (
        "CONCERT_PREMIUM",
        "Concert - Premium",
        1200000,
        "Vé khu vực gần sân khấu",
      ),
      ("THEATER", "Sân khấu kịch", 300000, "Một vé xem kịch tiêu chuẩn"),
      ("COMEDY", "Đêm hài độc thoại", 220000, "Một vé khu vực tiêu chuẩn"),
      ("SPORT", "Sự kiện thể thao", 350000, "Một vé khán đài tiêu chuẩn"),
      ("ESPORT", "Giải đấu Esports", 200000, "Một vé xem trực tiếp giải đấu"),
      (
        "WORKSHOP",
        "Workshop sáng tạo",
        180000,
        "Vé tham gia và tài liệu cơ bản",
      ),
      (
        "SEMINAR",
        "Hội thảo chuyên đề",
        300000,
        "Vé tham dự hội thảo trong ngày",
      ),
      ("EXHIBITION", "Triển lãm nghệ thuật", 150000, "Vé vào cửa một lượt"),
      (
        "FOOD_FEST",
        "Lễ hội ẩm thực",
        120000,
        "Vé vào cửa và voucher trải nghiệm",
      ),
      (
        "FAMILY_FEST",
        "Lễ hội gia đình",
        400000,
        "Vé dành cho hai người lớn và một trẻ em",
      ),
      (
        "KIDS_SHOW",
        "Chương trình thiếu nhi",
        180000,
        "Một vé trẻ em kèm người giám hộ",
      ),
      ("FASHION", "Tuần lễ thời trang", 600000, "Vé khu vực tiêu chuẩn"),
      ("TECH", "Sự kiện công nghệ", 350000, "Vé tham dự và tài liệu điện tử"),
      (
        "BUSINESS",
        "Kết nối doanh nghiệp",
        500000,
        "Vé tham dự và phiên kết nối",
      ),
      ("FAN_MEETING", "Fan meeting", 650000, "Vé tiêu chuẩn và quà lưu niệm"),
      ("EARLY_BIRD", "Vé Early Bird", 200000, "Vé ưu đãi đăng ký sớm"),
      (
        "GROUP_5",
        "Gói nhóm 5 người",
        1000000,
        "Năm vé tiêu chuẩn cùng sự kiện",
      ),
    ];

    return specs
        .map(
          (spec) => PackageModel(
            code: "TICKETBOX_${spec.$1}",
            name: "Ticketbox ${spec.$2}",
            price: spec.$3,
            description: spec.$4,
          ),
        )
        .toList(growable: false);
  }

  static int _roundPrice(int price) => ((price + 999) ~/ 1000) * 1000;

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
  static List<TripModel> getMockTrips(
    String serviceType,
    String from,
    String to,
  ) {
    List<TripModel> trips = [];
    final fromNorm = from.trim();
    final toNorm = to.trim();

    if (serviceType == 'bus') {
      final busBrands = [
        "Phương Trang",
        "Thành Bưởi",
        "Hải Âu",
        "Hoàng Long",
        "Kumho Samco",
        "Văn Minh",
        "Sao Việt",
        "VietBus",
        "Mai Linh",
      ];
      for (int i = 0; i < 50; i++) {
        trips.add(
          TripModel(
            brand: busBrands[i % busBrands.length],
            time:
                "${(i % 24).toString().padLeft(2, '0')}:${(i % 2 == 0) ? '00' : '30'} - ${((i + 6) % 24).toString().padLeft(2, '0')}:30",
            price: 180000 + (i * 2000),
            type: i % 5 == 0 ? "Limousine VIP" : "Giường nằm 36 chỗ",
            from: fromNorm,
            to: toNorm,
          ),
        );
      }
    } else if (serviceType == 'train') {
      for (int i = 1; i <= 40; i++) {
        trips.add(
          TripModel(
            brand: "Đường Sắt Việt Nam (Tàu SE$i/TN$i)",
            time:
                "${(i % 24).toString().padLeft(2, '0')}:15 - ${((i + 14) % 24).toString().padLeft(2, '0')}:45",
            price: 350000 + (i * 10000),
            type: i % 3 == 0 ? "Khoang 4 điều hòa" : "Ghế mềm điều hòa",
            from: fromNorm,
            to: toNorm,
          ),
        );
      }
    } else if (serviceType == 'plane') {
      final airlines = [
        "Vietnam Airlines",
        "Vietjet Air",
        "Bamboo Airways",
        "Vietravel Airlines",
      ];
      for (int i = 0; i < 40; i++) {
        trips.add(
          TripModel(
            brand: airlines[i % airlines.length],
            time:
                "${(i % 24).toString().padLeft(2, '0')}:00 - ${((i + 2) % 24).toString().padLeft(2, '0')}:10",
            price: 850000 + (i * 40000),
            type: i % 10 == 0 ? "Business Class" : "Economy Class",
            from: fromNorm,
            to: toNorm,
          ),
        );
      }
    } else {
      for (int i = 0; i < 20; i++) {
        trips.add(
          TripModel(
            brand: i % 2 == 0 ? "Grab" : "Xanh SM",
            time: "Ưu tiên đón ngay",
            price: 25000 + (i * 10000),
            type: i % 3 == 0 ? "Xe điện 5 chỗ" : "Xe xăng 4 chỗ",
            from: fromNorm,
            to: toNorm,
          ),
        );
      }
    }
    return trips;
  }

  // 🔹 5. Cấu hình Đối tác liên kết (Partners)
  static final List<Map<String, dynamic>> partners = [
    {
      "icon": Icons.local_taxi,
      "label": "Grab",
      "url": "https://www.grab.com/vn/",
    },
    {"icon": Icons.local_taxi, "label": "Be", "url": "https://be.com.vn/"},
    {"icon": Icons.movie, "label": "CGV", "url": "https://www.cgv.vn/"},
    {
      "icon": Icons.theaters,
      "label": "Galaxy Cinema",
      "url": "https://www.galaxycine.vn/",
    },
    {
      "icon": Icons.theaters,
      "label": "Lotte Cinema",
      "url": "https://www.lottecinemavn.com/",
    },
    {
      "icon": Icons.videogame_asset,
      "label": "Garena",
      "url": "https://napthe.vn/",
    },
    {"icon": Icons.tv, "label": "FPT Play", "url": "https://fptplay.vn/"},
    {
      "icon": Icons.shopping_bag,
      "label": "Shopee",
      "url": "https://shopee.vn/",
    },
    {
      "icon": Icons.shopping_cart,
      "label": "Lazada",
      "url": "https://www.lazada.vn/",
    },
    {"icon": Icons.restaurant, "label": "Baemin", "url": "https://baemin.vn/"},
    {
      "icon": Icons.delivery_dining,
      "label": "ShopeeFood",
      "url": "https://shopeefood.vn/",
    },
    {
      "icon": Icons.travel_explore,
      "label": "Traveloka",
      "url": "https://www.traveloka.com/vi-vn/",
    },
    {
      "icon": Icons.hotel,
      "label": "Agoda",
      "url": "https://www.agoda.com/vi-vn/",
    },
  ];
}
