import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FinancialServiceType { loan, insurance, saving }

class FinancialProduct {
  final String code;
  final String name;
  final String provider;
  final String description;
  final String highlight;
  final int amount;

  const FinancialProduct({
    required this.code,
    required this.name,
    required this.provider,
    required this.description,
    required this.highlight,
    required this.amount,
  });
}

class FinancialProductCatalog {
  FinancialProductCatalog._();

  static List<FinancialProduct> forType(FinancialServiceType type) {
    return switch (type) {
      FinancialServiceType.loan => loanProducts,
      FinancialServiceType.insurance => insuranceProducts,
      FinancialServiceType.saving => savingProducts,
    };
  }

  static const List<FinancialProduct> loanProducts = [
    FinancialProduct(
      code: 'LOAN_MINI_05',
      name: 'Vay Mini 5 triệu',
      provider: 'AnPay Finance',
      description: 'Khoản vay nhỏ cho nhu cầu chi tiêu ngắn hạn',
      highlight: 'Kỳ hạn đến 6 tháng',
      amount: 5000000,
    ),
    FinancialProduct(
      code: 'LOAN_MINI_10',
      name: 'Vay Mini 10 triệu',
      provider: 'AnPay Finance',
      description: 'Đăng ký tư vấn hoàn toàn trực tuyến',
      highlight: 'Kỳ hạn đến 9 tháng',
      amount: 10000000,
    ),
    FinancialProduct(
      code: 'LOAN_FLEX_15',
      name: 'Vay linh hoạt 15 triệu',
      provider: 'AnPay Finance',
      description: 'Lịch trả góp linh hoạt theo thu nhập',
      highlight: 'Kỳ hạn đến 12 tháng',
      amount: 15000000,
    ),
    FinancialProduct(
      code: 'LOAN_FLEX_20',
      name: 'Vay linh hoạt 20 triệu',
      provider: 'AnPay Finance',
      description: 'Phù hợp nhu cầu mua sắm thiết yếu',
      highlight: 'Kỳ hạn đến 12 tháng',
      amount: 20000000,
    ),
    FinancialProduct(
      code: 'LOAN_FLEX_30',
      name: 'Vay linh hoạt 30 triệu',
      provider: 'AnPay Finance',
      description: 'Tư vấn phương án trả góp theo hồ sơ',
      highlight: 'Kỳ hạn đến 18 tháng',
      amount: 30000000,
    ),
    FinancialProduct(
      code: 'LOAN_FLEX_50',
      name: 'Vay linh hoạt 50 triệu',
      provider: 'AnPay Finance',
      description: 'Dành cho khách hàng có thu nhập ổn định',
      highlight: 'Kỳ hạn đến 24 tháng',
      amount: 50000000,
    ),
    FinancialProduct(
      code: 'LOAN_STUDENT_10',
      name: 'Vay học tập 10 triệu',
      provider: 'AnPay Education',
      description: 'Hỗ trợ học phí và thiết bị học tập',
      highlight: 'Kỳ hạn đến 12 tháng',
      amount: 10000000,
    ),
    FinancialProduct(
      code: 'LOAN_STUDENT_20',
      name: 'Vay học tập 20 triệu',
      provider: 'AnPay Education',
      description: 'Hỗ trợ học phí cho khóa học dài hạn',
      highlight: 'Kỳ hạn đến 18 tháng',
      amount: 20000000,
    ),
    FinancialProduct(
      code: 'LOAN_WORKER_30',
      name: 'Vay cho người đi làm 30 triệu',
      provider: 'AnPay Finance',
      description: 'Xét duyệt dựa trên hồ sơ thu nhập',
      highlight: 'Kỳ hạn đến 18 tháng',
      amount: 30000000,
    ),
    FinancialProduct(
      code: 'LOAN_WORKER_50',
      name: 'Vay cho người đi làm 50 triệu',
      provider: 'AnPay Finance',
      description: 'Tư vấn lịch thanh toán hàng tháng',
      highlight: 'Kỳ hạn đến 24 tháng',
      amount: 50000000,
    ),
    FinancialProduct(
      code: 'LOAN_FAMILY_50',
      name: 'Vay gia đình 50 triệu',
      provider: 'AnPay Family',
      description: 'Phục vụ nhu cầu sửa chữa và mua sắm gia đình',
      highlight: 'Kỳ hạn đến 24 tháng',
      amount: 50000000,
    ),
    FinancialProduct(
      code: 'LOAN_FAMILY_100',
      name: 'Vay gia đình 100 triệu',
      provider: 'AnPay Family',
      description: 'Gói tư vấn tài chính cho hộ gia đình',
      highlight: 'Kỳ hạn đến 36 tháng',
      amount: 100000000,
    ),
    FinancialProduct(
      code: 'LOAN_HEALTH_30',
      name: 'Vay chăm sóc sức khỏe 30 triệu',
      provider: 'AnPay Health',
      description: 'Hỗ trợ chi phí khám và điều trị',
      highlight: 'Kỳ hạn đến 18 tháng',
      amount: 30000000,
    ),
    FinancialProduct(
      code: 'LOAN_HEALTH_70',
      name: 'Vay chăm sóc sức khỏe 70 triệu',
      provider: 'AnPay Health',
      description: 'Hỗ trợ kế hoạch điều trị dài hạn',
      highlight: 'Kỳ hạn đến 30 tháng',
      amount: 70000000,
    ),
    FinancialProduct(
      code: 'LOAN_VEHICLE_50',
      name: 'Vay mua xe máy 50 triệu',
      provider: 'AnPay Mobility',
      description: 'Tư vấn khoản vay mua xe máy',
      highlight: 'Kỳ hạn đến 24 tháng',
      amount: 50000000,
    ),
    FinancialProduct(
      code: 'LOAN_VEHICLE_80',
      name: 'Vay mua xe máy 80 triệu',
      provider: 'AnPay Mobility',
      description: 'Phù hợp các dòng xe máy cao cấp',
      highlight: 'Kỳ hạn đến 36 tháng',
      amount: 80000000,
    ),
    FinancialProduct(
      code: 'LOAN_SHOP_50',
      name: 'Vay hộ kinh doanh 50 triệu',
      provider: 'AnPay Business',
      description: 'Bổ sung vốn lưu động ngắn hạn',
      highlight: 'Kỳ hạn đến 18 tháng',
      amount: 50000000,
    ),
    FinancialProduct(
      code: 'LOAN_SHOP_100',
      name: 'Vay hộ kinh doanh 100 triệu',
      provider: 'AnPay Business',
      description: 'Bổ sung hàng hóa và thiết bị bán hàng',
      highlight: 'Kỳ hạn đến 24 tháng',
      amount: 100000000,
    ),
    FinancialProduct(
      code: 'LOAN_SHOP_150',
      name: 'Vay hộ kinh doanh 150 triệu',
      provider: 'AnPay Business',
      description: 'Tư vấn vốn cho hoạt động kinh doanh',
      highlight: 'Kỳ hạn đến 30 tháng',
      amount: 150000000,
    ),
    FinancialProduct(
      code: 'LOAN_SHOP_200',
      name: 'Vay hộ kinh doanh 200 triệu',
      provider: 'AnPay Business',
      description: 'Gói tư vấn theo dòng tiền kinh doanh',
      highlight: 'Kỳ hạn đến 36 tháng',
      amount: 200000000,
    ),
  ];

  static const List<FinancialProduct> insuranceProducts = [
    FinancialProduct(
      code: 'INS_TRAVEL_VN',
      name: 'Du lịch trong nước',
      provider: 'AnPay Insurance',
      description: 'Bảo vệ cho một chuyến đi trong nước',
      highlight: 'Quyền lợi minh họa đến 100 triệu',
      amount: 49000,
    ),
    FinancialProduct(
      code: 'INS_TRAVEL_ASIA',
      name: 'Du lịch châu Á',
      provider: 'AnPay Insurance',
      description: 'Bảo vệ cơ bản cho hành trình châu Á',
      highlight: 'Quyền lợi minh họa đến 300 triệu',
      amount: 159000,
    ),
    FinancialProduct(
      code: 'INS_TRAVEL_WORLD',
      name: 'Du lịch toàn cầu',
      provider: 'AnPay Insurance',
      description: 'Bảo vệ cho hành trình quốc tế',
      highlight: 'Quyền lợi minh họa đến 500 triệu',
      amount: 299000,
    ),
    FinancialProduct(
      code: 'INS_ACCIDENT_BASIC',
      name: 'Tai nạn cá nhân Cơ bản',
      provider: 'AnPay Insurance',
      description: 'Hỗ trợ rủi ro tai nạn trong 12 tháng',
      highlight: 'Quyền lợi minh họa đến 100 triệu',
      amount: 120000,
    ),
    FinancialProduct(
      code: 'INS_ACCIDENT_PLUS',
      name: 'Tai nạn cá nhân Nâng cao',
      provider: 'AnPay Insurance',
      description: 'Mở rộng mức hỗ trợ do tai nạn',
      highlight: 'Quyền lợi minh họa đến 300 triệu',
      amount: 290000,
    ),
    FinancialProduct(
      code: 'INS_ACCIDENT_FAMILY',
      name: 'Tai nạn gia đình',
      provider: 'AnPay Family',
      description: 'Gói bảo vệ minh họa cho bốn thành viên',
      highlight: 'Thời hạn 12 tháng',
      amount: 690000,
    ),
    FinancialProduct(
      code: 'INS_HEALTH_BASIC',
      name: 'Sức khỏe Cơ bản',
      provider: 'AnPay Health',
      description: 'Hỗ trợ chi phí điều trị nội trú',
      highlight: 'Quyền lợi minh họa đến 100 triệu',
      amount: 990000,
    ),
    FinancialProduct(
      code: 'INS_HEALTH_PLUS',
      name: 'Sức khỏe Nâng cao',
      provider: 'AnPay Health',
      description: 'Mở rộng quyền lợi nội trú và ngoại trú',
      highlight: 'Quyền lợi minh họa đến 300 triệu',
      amount: 1990000,
    ),
    FinancialProduct(
      code: 'INS_HEALTH_PREMIUM',
      name: 'Sức khỏe Cao cấp',
      provider: 'AnPay Health',
      description: 'Gói chăm sóc sức khỏe mở rộng',
      highlight: 'Quyền lợi minh họa đến 500 triệu',
      amount: 3490000,
    ),
    FinancialProduct(
      code: 'INS_HEALTH_CHILD',
      name: 'Sức khỏe trẻ em',
      provider: 'AnPay Health',
      description: 'Gói minh họa dành cho trẻ từ 1 tuổi',
      highlight: 'Thời hạn 12 tháng',
      amount: 1490000,
    ),
    FinancialProduct(
      code: 'INS_HEALTH_SENIOR',
      name: 'Sức khỏe người cao tuổi',
      provider: 'AnPay Health',
      description: 'Gói tư vấn quyền lợi theo độ tuổi',
      highlight: 'Thời hạn 12 tháng',
      amount: 2490000,
    ),
    FinancialProduct(
      code: 'INS_MOTOR_BASIC',
      name: 'Xe máy bắt buộc',
      provider: 'AnPay Mobility',
      description: 'Chứng nhận điện tử sau khi hoàn tất',
      highlight: 'Thời hạn 12 tháng',
      amount: 66000,
    ),
    FinancialProduct(
      code: 'INS_MOTOR_PLUS',
      name: 'Xe máy mở rộng',
      provider: 'AnPay Mobility',
      description: 'Bổ sung quyền lợi tai nạn người ngồi xe',
      highlight: 'Thời hạn 12 tháng',
      amount: 126000,
    ),
    FinancialProduct(
      code: 'INS_CAR_CIVIL',
      name: 'Ô tô trách nhiệm dân sự',
      provider: 'AnPay Mobility',
      description: 'Gói trách nhiệm dân sự minh họa',
      highlight: 'Thời hạn 12 tháng',
      amount: 480000,
    ),
    FinancialProduct(
      code: 'INS_CAR_BODY',
      name: 'Ô tô vật chất cơ bản',
      provider: 'AnPay Mobility',
      description: 'Tư vấn bảo vệ vật chất xe theo giá trị',
      highlight: 'Phí minh họa ban đầu',
      amount: 2500000,
    ),
    FinancialProduct(
      code: 'INS_HOME_BASIC',
      name: 'Nhà ở an tâm',
      provider: 'AnPay Family',
      description: 'Bảo vệ minh họa cho tài sản trong nhà',
      highlight: 'Thời hạn 12 tháng',
      amount: 390000,
    ),
    FinancialProduct(
      code: 'INS_HOME_PLUS',
      name: 'Nhà ở toàn diện',
      provider: 'AnPay Family',
      description: 'Mở rộng phạm vi bảo vệ tài sản',
      highlight: 'Thời hạn 12 tháng',
      amount: 790000,
    ),
    FinancialProduct(
      code: 'INS_PHONE',
      name: 'Thiết bị di động',
      provider: 'AnPay Digital',
      description: 'Hỗ trợ rơi vỡ và hư hỏng thiết bị',
      highlight: 'Thời hạn 12 tháng',
      amount: 299000,
    ),
    FinancialProduct(
      code: 'INS_LAPTOP',
      name: 'Máy tính cá nhân',
      provider: 'AnPay Digital',
      description: 'Hỗ trợ rủi ro thiết bị học tập và làm việc',
      highlight: 'Thời hạn 12 tháng',
      amount: 499000,
    ),
    FinancialProduct(
      code: 'INS_SHOP',
      name: 'Hộ kinh doanh an tâm',
      provider: 'AnPay Business',
      description: 'Gói bảo vệ tài sản cửa hàng minh họa',
      highlight: 'Thời hạn 12 tháng',
      amount: 1290000,
    ),
  ];

  static const List<FinancialProduct> savingProducts = [
    FinancialProduct(
      code: 'SAVE_01W',
      name: 'Tích lũy 1 tuần',
      provider: 'AnPay Savings',
      description: 'Bắt đầu tích lũy với thời gian ngắn',
      highlight: 'Kỳ hạn 1 tuần',
      amount: 100000,
    ),
    FinancialProduct(
      code: 'SAVE_02W',
      name: 'Tích lũy 2 tuần',
      provider: 'AnPay Savings',
      description: 'Phù hợp mục tiêu chi tiêu gần',
      highlight: 'Kỳ hạn 2 tuần',
      amount: 100000,
    ),
    FinancialProduct(
      code: 'SAVE_01M',
      name: 'Tiết kiệm 1 tháng',
      provider: 'AnPay Savings',
      description: 'Kỳ hạn ngắn, số tiền khởi điểm thấp',
      highlight: 'Kỳ hạn 1 tháng',
      amount: 200000,
    ),
    FinancialProduct(
      code: 'SAVE_02M',
      name: 'Tiết kiệm 2 tháng',
      provider: 'AnPay Savings',
      description: 'Tích lũy cho kế hoạch ngắn hạn',
      highlight: 'Kỳ hạn 2 tháng',
      amount: 200000,
    ),
    FinancialProduct(
      code: 'SAVE_03M',
      name: 'Tiết kiệm 3 tháng',
      provider: 'AnPay Savings',
      description: 'Tích lũy định kỳ theo quý',
      highlight: 'Kỳ hạn 3 tháng',
      amount: 500000,
    ),
    FinancialProduct(
      code: 'SAVE_06M',
      name: 'Tiết kiệm 6 tháng',
      provider: 'AnPay Savings',
      description: 'Tích lũy cho mục tiêu trung hạn',
      highlight: 'Kỳ hạn 6 tháng',
      amount: 500000,
    ),
    FinancialProduct(
      code: 'SAVE_09M',
      name: 'Tiết kiệm 9 tháng',
      provider: 'AnPay Savings',
      description: 'Kế hoạch tích lũy linh hoạt',
      highlight: 'Kỳ hạn 9 tháng',
      amount: 500000,
    ),
    FinancialProduct(
      code: 'SAVE_12M',
      name: 'Tiết kiệm 12 tháng',
      provider: 'AnPay Savings',
      description: 'Tích lũy đều đặn trong một năm',
      highlight: 'Kỳ hạn 12 tháng',
      amount: 1000000,
    ),
    FinancialProduct(
      code: 'SAVE_18M',
      name: 'Tiết kiệm 18 tháng',
      provider: 'AnPay Savings',
      description: 'Dành cho mục tiêu dài hơn một năm',
      highlight: 'Kỳ hạn 18 tháng',
      amount: 1000000,
    ),
    FinancialProduct(
      code: 'SAVE_24M',
      name: 'Tiết kiệm 24 tháng',
      provider: 'AnPay Savings',
      description: 'Kế hoạch tích lũy trong hai năm',
      highlight: 'Kỳ hạn 24 tháng',
      amount: 2000000,
    ),
    FinancialProduct(
      code: 'SAVE_36M',
      name: 'Tiết kiệm 36 tháng',
      provider: 'AnPay Savings',
      description: 'Kế hoạch tích lũy dài hạn',
      highlight: 'Kỳ hạn 36 tháng',
      amount: 2000000,
    ),
    FinancialProduct(
      code: 'SAVE_EDU_06',
      name: 'Quỹ học tập 6 tháng',
      provider: 'AnPay Goals',
      description: 'Tạo quỹ cho học phí và khóa học',
      highlight: 'Mục tiêu 6 tháng',
      amount: 500000,
    ),
    FinancialProduct(
      code: 'SAVE_EDU_12',
      name: 'Quỹ học tập 12 tháng',
      provider: 'AnPay Goals',
      description: 'Chuẩn bị học phí cho năm tiếp theo',
      highlight: 'Mục tiêu 12 tháng',
      amount: 1000000,
    ),
    FinancialProduct(
      code: 'SAVE_TRAVEL_06',
      name: 'Quỹ du lịch 6 tháng',
      provider: 'AnPay Goals',
      description: 'Tích lũy cho chuyến đi sắp tới',
      highlight: 'Mục tiêu 6 tháng',
      amount: 500000,
    ),
    FinancialProduct(
      code: 'SAVE_TRAVEL_12',
      name: 'Quỹ du lịch 12 tháng',
      provider: 'AnPay Goals',
      description: 'Lập kế hoạch du lịch trong một năm',
      highlight: 'Mục tiêu 12 tháng',
      amount: 1000000,
    ),
    FinancialProduct(
      code: 'SAVE_HOME_12',
      name: 'Quỹ gia đình 12 tháng',
      provider: 'AnPay Family',
      description: 'Tích lũy cho nhu cầu chung của gia đình',
      highlight: 'Mục tiêu 12 tháng',
      amount: 1000000,
    ),
    FinancialProduct(
      code: 'SAVE_HOME_24',
      name: 'Quỹ gia đình 24 tháng',
      provider: 'AnPay Family',
      description: 'Tích lũy cho kế hoạch gia đình dài hạn',
      highlight: 'Mục tiêu 24 tháng',
      amount: 2000000,
    ),
    FinancialProduct(
      code: 'SAVE_EMERGENCY',
      name: 'Quỹ dự phòng',
      provider: 'AnPay Goals',
      description: 'Tạo khoản dự phòng cho tình huống bất ngờ',
      highlight: 'Nạp thêm linh hoạt',
      amount: 500000,
    ),
    FinancialProduct(
      code: 'SAVE_BUSINESS',
      name: 'Quỹ kinh doanh',
      provider: 'AnPay Business',
      description: 'Tích lũy vốn cho hộ kinh doanh',
      highlight: 'Nạp thêm linh hoạt',
      amount: 2000000,
    ),
    FinancialProduct(
      code: 'SAVE_ROUNDUP',
      name: 'Tích lũy mỗi ngày',
      provider: 'AnPay Savings',
      description: 'Khởi tạo mục tiêu tiết kiệm hằng ngày',
      highlight: 'Nạp thêm bất cứ lúc nào',
      amount: 100000,
    ),
  ];
}

class FinancialServiceScreen extends StatefulWidget {
  final FinancialServiceType type;

  const FinancialServiceScreen({super.key, required this.type});

  @override
  State<FinancialServiceScreen> createState() => _FinancialServiceScreenState();
}

class _FinancialServiceScreenState extends State<FinancialServiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  FinancialProduct? _selectedProduct;
  String _query = '';

  List<FinancialProduct> get _products =>
      FinancialProductCatalog.forType(widget.type);

  List<FinancialProduct> get _visibleProducts {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.provider.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  String get _title => switch (widget.type) {
    FinancialServiceType.loan => 'Vay tiền mặt',
    FinancialServiceType.insurance => 'Mua bảo hiểm',
    FinancialServiceType.saving => 'Gửi tiết kiệm',
  };

  String get _intro => switch (widget.type) {
    FinancialServiceType.loan =>
      'Chọn hạn mức phù hợp và gửi yêu cầu để được tư vấn.',
    FinancialServiceType.insurance =>
      'Chọn gói bảo vệ, xem phí minh họa và thanh toán bằng ví.',
    FinancialServiceType.saving =>
      'Chọn mục tiêu, kỳ hạn và số tiền khởi tạo phù hợp.',
  };

  String get _amountLabel => switch (widget.type) {
    FinancialServiceType.loan => 'Hạn mức đến',
    FinancialServiceType.insurance => 'Phí từ',
    FinancialServiceType.saving => 'Khởi tạo từ',
  };

  String get _actionLabel => switch (widget.type) {
    FinancialServiceType.loan => 'ĐĂNG KÝ TƯ VẤN',
    FinancialServiceType.insurance => 'THANH TOÁN PHÍ',
    FinancialServiceType.saving => 'MỞ SỔ TIẾT KIỆM',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.purple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$_intro\nDữ liệu và quyền lợi hiện tại chỉ dùng để mô phỏng.',
                          style: TextStyle(
                            color: Colors.purple.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('financial-product-search'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm sản phẩm hoặc nhà cung cấp',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_visibleProducts.length} sản phẩm',
                  key: const Key('financial-product-count'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (_visibleProducts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text('Không tìm thấy sản phẩm phù hợp'),
                    ),
                  )
                else
                  ..._visibleProducts.map(_buildProductCard),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                key: const Key('financial-action-button'),
                onPressed: _selectedProduct == null ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(FinancialProduct product) {
    final isSelected = identical(_selectedProduct, product);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        key: Key('financial-product-${product.code}'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedProduct = product),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.purple.withValues(alpha: 0.06)
                : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.provider,
                          style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                product.description,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTag(product.highlight),
                  _buildTag(
                    '$_amountLabel ${NumberFormat.decimalPattern('vi_VN').format(product.amount)}đ',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  void _continue() {
    AppLogger.action('FINANCIAL SERVICE continue pressed', {'product': _selectedProduct?.name});
    final product = _selectedProduct!;
    if (widget.type == FinancialServiceType.loan) {
      _showLoanApplication(product);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyFormScreen(
          account: PaymentAccount.fromService(
            serviceName: _title,
            provider: product.provider,
            detail: product.name,
            accountNumber: 'FIN/${product.code}',
          ),
          presetAmount: product.amount,
        ),
      ),
    );
  }

  Future<void> _showLoanApplication(FinancialProduct product) async {
    AppLogger.action('FINANCIAL SERVICE loan application opened', {'product': product.name});
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();
    final amountController = TextEditingController(
      text: product.amount.toString(),
    );

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đăng ký ${product.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AnPay sẽ dùng thông tin này để liên hệ tư vấn. Đây là biểu mẫu mô phỏng.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final digits = (value ?? '').replaceAll(
                        RegExp(r'\D'),
                        '',
                      );
                      return digits.length < 9
                          ? 'Vui lòng nhập số điện thoại hợp lệ'
                          : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền muốn vay',
                      suffixText: 'đ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount =
                          int.tryParse(
                            (value ?? '').replaceAll(RegExp(r'\D'), ''),
                          ) ??
                          0;
                      if (amount < 1000000) {
                        return 'Số tiền tối thiểu là 1.000.000đ';
                      }
                      if (amount > product.amount) {
                        return 'Số tiền vượt quá hạn mức đã chọn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(sheetContext, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('GỬI YÊU CẦU'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    phoneController.dispose();
    amountController.dispose();
    if (submitted != true || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 52),
        title: const Text('Đã tiếp nhận yêu cầu'),
        content: const Text(
          'Yêu cầu tư vấn mô phỏng đã được ghi nhận. Không có khoản vay thật nào được tạo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ĐÓNG'),
          ),
        ],
      ),
    );
  }
}
