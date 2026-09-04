import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app_do_an/navigator/navigator_screen/bill_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/financial_service_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/lottery_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/notification_center_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/qr_main_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/service_category_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/travel_screen.dart';
import 'package:app_do_an/navigator/navigator_tabbar/topup_tabbar.dart';
import 'package:app_do_an/navigator/navigator_tabbar/telecom_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/recharge_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/telecom/generic_package_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transfermoney_screen.dart';
import 'package:app_do_an/navigator/service/app_data.dart';
import 'package:app_do_an/navigator/service/partner_link_service.dart';
import 'schedule_tabbar.dart';

class HomeTabbar extends StatefulWidget {
  final bool refreshHeaderOnStart;

  const HomeTabbar({super.key, this.refreshHeaderOnStart = true});

  @override
  State<HomeTabbar> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends State<HomeTabbar> {
  static final List<Map<String, dynamic>> _popularItems = [
    {"icon": Icons.phone_android, "label": "Viễn thông"},
    {"icon": Icons.local_activity, "label": "Xổ số, giải trí"},
    {"icon": Icons.receipt_long, "label": "Hóa đơn"},
    {"icon": Icons.flight_takeoff, "label": "Du lịch, đi lại"},
    {"icon": Icons.attach_money, "label": "Vay tiền mặt"},
    {"icon": Icons.health_and_safety, "label": "Mua bảo hiểm"},
    {"icon": Icons.savings, "label": "Gửi tiết kiệm"},
    {"icon": Icons.apps, "label": "Xem tất cả"},
  ];

  static final List<Map<String, dynamic>> _catalogOnlyItems = [
    {"icon": Icons.network_wifi, "label": "Đăng ký 3G/4G"},
    {"icon": Icons.live_tv, "label": "Internet/TV"},
    {"icon": Icons.shopping_bag, "label": "Mua sắm"},
    {"icon": Icons.restaurant, "label": "Ăn uống"},
    {"icon": Icons.school, "label": "Giáo dục"},
    {"icon": Icons.local_hospital, "label": "Y tế"},
    {"icon": Icons.directions_car, "label": "Giao thông"},
    {"icon": Icons.volunteer_activism, "label": "Quyên góp"},
    {"icon": Icons.cloud, "label": "Dịch vụ số"},
  ];

  static final List<Map<String, dynamic>> _partnerItems = [
    {"icon": Icons.videogame_asset, "label": "Garena"},
    {"icon": Icons.movie, "label": "CGV"},
    {"icon": Icons.theaters, "label": "Galaxy"},
    {"icon": Icons.local_shipping, "label": "SPX"},
    {"icon": Icons.tv, "label": "FPT Play"},
    {"icon": Icons.confirmation_num, "label": "Ticketbox"},
    {"icon": Icons.video_library, "label": "VieON"},
    {"icon": Icons.apps, "label": "Xem thêm"},
  ];

  bool _isHidden = true;
  int _walletBalance = 0;
  int _unreadNotificationCount = 0;

  final GlobalKey<ScheduleTabbarState> scheduleKey =
      GlobalKey<ScheduleTabbarState>();

  @override
  void initState() {
    super.initState();
    if (widget.refreshHeaderOnStart) _refreshHomeHeader();
  }

  Future<void> _refreshHomeHeader() async {
    await Future.wait([_loadBalance(), _loadUnreadCount()]);
  }

  Future<void> _loadBalance() async {
    AppLogger.repo('HOME_UI', 'Refreshing wallet balance');
    try {
      final wallet = await AppServices.wallet.me();
      final currentBalance = (wallet['availableBalance'] as num?)?.toInt() ?? 0;
      if (mounted) {
        setState(() => _walletBalance = currentBalance);
        AppLogger.success('HOME_UI', 'Wallet balance refreshed', {
          'availableBalance': currentBalance,
        });
      }
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'HOME_UI',
        'Wallet balance refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _loadUnreadCount() async {
    AppLogger.repo('HOME_UI', 'Refreshing unread notification count');
    try {
      final count = await AppServices.notification.unreadCount();
      if (!mounted) return;
      setState(() => _unreadNotificationCount = count);
      AppLogger.success('HOME_UI', 'Unread notification count refreshed', {
        'count': count,
      });
    } on ApiException catch (e, stackTrace) {
      AppLogger.error(
        'HOME_UI',
        'Unread notification count refresh failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text("AnPay", style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Trung tâm thông báo",
            onPressed: () async {
              AppLogger.action('HOME: notifications button pressed');
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationCenterScreen(),
                ),
              );
              _loadUnreadCount();
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.purple, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : _unreadNotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Tổng số dư
            Container(
              width: double.infinity,
              color: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tổng số dư",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _isHidden
                            ? "đ ***"
                            : "đ ${NumberFormat("#,###").format(_walletBalance)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          AppLogger.action('HOME: balance visibility toggled', {
                            'visible': _isHidden,
                          });
                          setState(() => _isHidden = !_isHidden);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 Button nhanh
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _quickButton(context, Icons.add_card, "Nạp tiền", () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RechargeScreen()),
                    );
                    _refreshHomeHeader();
                  }),
                  _quickButton(context, Icons.send, "Chuyển tiền", () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransferMoneyScreen(),
                      ),
                    );
                    _refreshHomeHeader();
                  }),
                  _quickButton(
                    context,
                    Icons.qr_code_scanner,
                    "QR của tôi",
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrMainScreen()),
                      );
                    },
                  ),
                  _quickButton(
                    context,
                    Icons.local_activity,
                    "Ưu đãi",
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const TopUpTabbar(showBackButton: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // 🔹 TabBar + Grid menu
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.purple,
                    unselectedLabelColor: Colors.black,
                    indicatorColor: Colors.purple,
                    tabs: [
                      Tab(text: "Phổ biến"),
                      Tab(text: "Ưu đãi Đối tác"),
                    ],
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildGrid(_popularItems),
                        _buildGrid(_partnerItems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              AppLogger.action('HOME quick action pressed', {'label': label});
              onTap();
            },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.shade50,
            radius: 28,
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _handleMenuItem(Map<String, dynamic> item) async {
    final label = item["label"] as String;
    AppLogger.action('HOME service pressed', {'label': label});
    final partnerPackages = AppData.partnerPackagesByProvider[label];
    if (partnerPackages != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GenericPackageScreen(
            title: "Thanh toán $label",
            providers: [label],
            packagesByProvider: {label: partnerPackages},
            providerLabel: "Đối tác",
            packageLabel:
                AppData.partnerItemLabels[label] ?? "Chọn gói hoặc dịch vụ",
            searchHint: "Tìm trong danh mục $label",
            actionLabel: "THANH TOÁN NGAY",
            itemUnit: "lựa chọn",
            selectionLabel: "Lựa chọn",
          ),
        ),
      );
      if (mounted) _loadBalance();
      return;
    }

    final partnerUrl = PartnerLinkService.urlFor(label);
    if (partnerUrl != null) {
      AppLogger.repo('HOME_UI', 'Opening partner link', {'partner': label});
      final opened = await PartnerLinkService.open(label);
      AppLogger.repo('HOME_UI', 'Partner link result', {
        'partner': label,
        'opened': opened,
      });
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Không thể mở trang $label. Vui lòng thử lại."),
          ),
        );
      }
      return;
    }

    switch (label) {
      case "Viễn thông":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelecomScreen(walletBalance: _walletBalance),
          ),
        );
        break;
      case "Xổ số, giải trí":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LotteryScreen(walletBalance: _walletBalance),
          ),
        );
        break;
      case "Hóa đơn":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BillScreen()),
        );
        break;
      case "Du lịch, đi lại":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TravelScreen(walletBalance: _walletBalance),
          ),
        );
        break;
      case "Vay tiền mặt":
        await _openFinancialService(FinancialServiceType.loan);
        break;
      case "Mua bảo hiểm":
        await _openFinancialService(FinancialServiceType.insurance);
        break;
      case "Gửi tiết kiệm":
        await _openFinancialService(FinancialServiceType.saving);
        break;
      case "Đăng ký 3G/4G":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenericPackageScreen(
              title: "Đăng ký 3G/4G",
              providers: const ["Viettel", "MobiFone", "VinaPhone"],
              packagesByProvider: AppData.dataPackagesByProvider,
            ),
          ),
        );
        break;
      case "Internet/TV":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenericPackageScreen(
              title: "Internet/Truyền hình",
              providers: const ["FPT Play", "K+", "VieON"],
              packagesByProvider: AppData.tvPackagesByProvider,
            ),
          ),
        );
        break;
      case "Mua sắm":
        await _openLevelOneService(
          title: "Mua sắm",
          subtitle: "Các tiện ích mua sắm độc lập của AnPay. Những dịch vụ con của các nhóm cũ vẫn được giữ nguyên ở đúng nhóm của chúng.",
          services: const [
            ServiceCategoryItem(
              label: "Siêu thị & cửa hàng",
              icon: Icons.storefront,
              description: "Thanh toán và sử dụng các tiện ích dành cho hệ thống siêu thị, cửa hàng bán lẻ liên kết.",
            ),
            ServiceCategoryItem(
              label: "Thương mại điện tử",
              icon: Icons.shopping_cart,
              description: "Các tiện ích thanh toán dành cho nền tảng mua sắm trực tuyến liên kết với AnPay.",
            ),
            ServiceCategoryItem(
              label: "Voucher mua sắm",
              icon: Icons.card_giftcard,
              description: "Khám phá và sử dụng voucher mua sắm từ các đối tác bán lẻ.",
            ),
            ServiceCategoryItem(
              label: "Thanh toán tại quầy",
              icon: Icons.point_of_sale,
              description: "Tiện ích thanh toán tại cửa hàng hoặc điểm bán thuộc hệ thống đối tác.",
            ),
          ],
        );
        break;
      case "Ăn uống":
        await _openLevelOneService(
          title: "Ăn uống",
          subtitle: "Nhóm tiện ích dành riêng cho ăn uống, không lấy các dịch vụ con từ Viễn thông, Hóa đơn, Giải trí hay Du lịch ra ngoài.",
          services: const [
            ServiceCategoryItem(
              label: "Đặt món",
              icon: Icons.delivery_dining,
              description: "Tìm và đặt món từ các nhà hàng, quán ăn và đối tác giao đồ ăn liên kết.",
            ),
            ServiceCategoryItem(
              label: "Đặt bàn",
              icon: Icons.table_restaurant,
              description: "Đặt bàn trước tại nhà hàng hoặc quán ăn thuộc hệ thống đối tác.",
            ),
            ServiceCategoryItem(
              label: "Cà phê & đồ uống",
              icon: Icons.local_cafe,
              description: "Tiện ích dành cho chuỗi cà phê, trà sữa và cửa hàng đồ uống.",
            ),
            ServiceCategoryItem(
              label: "Ưu đãi ẩm thực",
              icon: Icons.local_offer,
              description: "Tổng hợp chương trình ưu đãi và voucher dành riêng cho ăn uống.",
            ),
          ],
        );
        break;
      case "Giáo dục":
        await _openLevelOneService(
          title: "Giáo dục",
          subtitle: "Các dịch vụ giáo dục bổ sung. Mục Học phí hiện có vẫn nằm trong Hóa đơn và không bị đưa ra đây.",
          services: const [
            ServiceCategoryItem(
              label: "Khóa học trực tuyến",
              icon: Icons.laptop_chromebook,
              description: "Khám phá các khóa học trực tuyến từ nền tảng đào tạo liên kết.",
            ),
            ServiceCategoryItem(
              label: "Sách & học liệu",
              icon: Icons.menu_book,
              description: "Mua sách, giáo trình và học liệu số từ các nhà cung cấp đối tác.",
            ),
            ServiceCategoryItem(
              label: "Luyện thi",
              icon: Icons.quiz,
              description: "Các gói luyện thi, ngân hàng câu hỏi và dịch vụ ôn tập trực tuyến.",
            ),
            ServiceCategoryItem(
              label: "Chứng chỉ kỹ năng",
              icon: Icons.workspace_premium,
              description: "Đăng ký các chương trình đào tạo và chứng chỉ kỹ năng từ đối tác.",
            ),
          ],
        );
        break;
      case "Y tế":
        await _openLevelOneService(
          title: "Y tế",
          subtitle: "Nhóm tiện ích chăm sóc sức khỏe và y tế độc lập, tách biệt với mục Mua bảo hiểm hiện có.",
          services: const [
            ServiceCategoryItem(
              label: "Đặt lịch khám",
              icon: Icons.calendar_month,
              description: "Đặt lịch khám tại bệnh viện, phòng khám hoặc cơ sở y tế liên kết.",
            ),
            ServiceCategoryItem(
              label: "Gói khám sức khỏe",
              icon: Icons.medical_services,
              description: "Đăng ký các gói khám tổng quát hoặc chuyên khoa từ đối tác y tế.",
            ),
            ServiceCategoryItem(
              label: "Xét nghiệm tại nhà",
              icon: Icons.science,
              description: "Đặt dịch vụ lấy mẫu hoặc xét nghiệm tại nhà từ đơn vị liên kết.",
            ),
            ServiceCategoryItem(
              label: "Nhà thuốc",
              icon: Icons.local_pharmacy,
              description: "Tiện ích mua sắm và thanh toán tại các nhà thuốc đối tác.",
            ),
          ],
        );
        break;
      case "Giao thông":
        await _openLevelOneService(
          title: "Giao thông",
          subtitle: "Các tiện ích giao thông thường ngày. Vé máy bay, tàu, xe khách, taxi và thuê xe vẫn giữ nguyên trong Du lịch, đi lại.",
          services: const [
            ServiceCategoryItem(
              label: "Thu phí không dừng",
              icon: Icons.toll,
              description: "Quản lý hoặc nạp tiền cho dịch vụ thu phí giao thông không dừng.",
              action: ServiceCategoryAction.toll,
            ),
            ServiceCategoryItem(
              label: "Phí đỗ xe",
              icon: Icons.local_parking,
              description: "Thanh toán phí gửi xe tại các bãi đỗ và điểm đỗ liên kết.",
            ),
            ServiceCategoryItem(
              label: "Cứu hộ phương tiện",
              icon: Icons.car_repair,
              description: "Kết nối dịch vụ cứu hộ và hỗ trợ phương tiện trên đường.",
            ),
            ServiceCategoryItem(
              label: "Sạc xe điện",
              icon: Icons.ev_station,
              description: "Tìm điểm sạc và thanh toán dịch vụ sạc xe điện tại đối tác hỗ trợ.",
            ),
          ],
        );
        break;
      case "Quyên góp":
        await _openLevelOneService(
          title: "Quyên góp",
          subtitle: "Các chương trình đóng góp cộng đồng được tổ chức thành một nhóm dịch vụ riêng.",
          services: const [
            ServiceCategoryItem(
              label: "Hỗ trợ trẻ em",
              icon: Icons.child_care,
              description: "Đóng góp cho các chương trình hỗ trợ trẻ em có hoàn cảnh khó khăn.",
            ),
            ServiceCategoryItem(
              label: "Cứu trợ thiên tai",
              icon: Icons.warning,
              description: "Ủng hộ các chương trình cứu trợ và phục hồi sau thiên tai.",
            ),
            ServiceCategoryItem(
              label: "Y tế cộng đồng",
              icon: Icons.favorite_border,
              description: "Đóng góp cho chương trình y tế và chăm sóc sức khỏe cộng đồng.",
            ),
            ServiceCategoryItem(
              label: "Bảo vệ môi trường",
              icon: Icons.eco,
              description: "Ủng hộ các hoạt động bảo vệ môi trường và phát triển bền vững.",
            ),
          ],
        );
        break;
      case "Dịch vụ số":
        await _openLevelOneService(
          title: "Dịch vụ số",
          subtitle: "Nhóm tiện ích công nghệ số mới, không trùng với Internet/TV hay các gói viễn thông hiện có.",
          services: const [
            ServiceCategoryItem(
              label: "Lưu trữ đám mây",
              icon: Icons.cloud_queue,
              description: "Đăng ký và thanh toán các gói lưu trữ đám mây từ đối tác.",
            ),
            ServiceCategoryItem(
              label: "Phần mềm",
              icon: Icons.apps,
              description: "Mua hoặc gia hạn phần mềm và dịch vụ số dành cho cá nhân.",
            ),
            ServiceCategoryItem(
              label: "Tên miền & Hosting",
              icon: Icons.language,
              description: "Đăng ký hoặc gia hạn tên miền, hosting và dịch vụ website.",
            ),
            ServiceCategoryItem(
              label: "Chữ ký số",
              icon: Icons.edit,
              description: "Đăng ký và gia hạn dịch vụ chữ ký số từ nhà cung cấp liên kết.",
            ),
          ],
        );
        break;
      case "Xem tất cả":
        await _showServiceCatalog(partnersOnly: false);
        break;
      case "Xem thêm":
        await _showServiceCatalog(partnersOnly: true);
        break;
    }

    if (mounted) _loadBalance();
  }

  Future<void> _openFinancialService(FinancialServiceType type) async {
    AppLogger.action('HOME financial service opened', {
      'type': type.toString(),
    });
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FinancialServiceScreen(type: type)),
    );
  }

  Future<void> _openLevelOneService({
    required String title,
    required String subtitle,
    required List<ServiceCategoryItem> services,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceCategoryScreen(
          title: title,
          subtitle: subtitle,
          services: services,
        ),
      ),
    );
  }

  Future<void> _showServiceCatalog({required bool partnersOnly}) async {
    AppLogger.action('HOME service catalog opened', {
      'partnersOnly': partnersOnly,
    });
    final serviceItems = [
      ..._popularItems.where((item) => item["label"] != "Xem tất cả"),
      ..._catalogOnlyItems,
    ];
    final partnerItems = _partnerItems
        .where((item) => item["label"] != "Xem thêm")
        .toList(growable: false);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          key: ValueKey(
            partnersOnly ? 'partner-catalog-sheet' : 'service-catalog-sheet',
          ),
          heightFactor: 0.86,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        partnersOnly ? "Tất cả đối tác" : "Tất cả dịch vụ",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: "Đóng",
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    if (partnersOnly)
                      _buildCatalogSection(
                        sheetContext,
                        title: "Đối tác",
                        items: partnerItems,
                      )
                    else
                      _buildCatalogSection(
                        sheetContext,
                        title: "Dịch vụ AnPay",
                        items: serviceItems,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatalogSection(
    BuildContext sheetContext, {
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                AppLogger.action('HOME catalog item pressed', {
                  'label': item['label'],
                });
                Navigator.pop(sheetContext);
                await Future<void>.delayed(const Duration(milliseconds: 180));
                if (mounted) await _handleMenuItem(item);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.red.shade50,
                    child: Icon(item["icon"] as IconData, color: Colors.purple),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item["label"] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            AppLogger.action('HOME grid item pressed', {
              'label': item['label'],
            });
            _handleMenuItem(item);
          },
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade50,
                radius: 26,
                child: Icon(item["icon"], color: Colors.purple),
              ),
              const SizedBox(height: 6),
              Text(
                item["label"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
