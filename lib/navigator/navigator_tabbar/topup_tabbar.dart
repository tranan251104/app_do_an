import 'package:flutter/material.dart';

class TopUpTabbar extends StatefulWidget {
  final bool showBackButton;
  const TopUpTabbar({super.key, this.showBackButton = false});

  @override
  State<TopUpTabbar> createState() => _TopUpTabbarState();
}

class _TopUpTabbarState extends State<TopUpTabbar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = "Tất cả";

  final List<String> categories = [
    "Tất cả",
    "Ăn uống",
    "Di chuyển",
    "Mua sắm",
    "Công nghệ",
    "Du lịch",
    "Sức khỏe",
    "Giáo dục",
    "Giải trí",
  ];

  final promotions = [
     
  {
    "logo": Icons.train,
    "brand": "Đường sắt Việt Nam",
    "desc": "Giảm 10% tối đa 100K",
    "note": "Thanh toán qua website",
    "date": "30.09.2025",
    "category": "Di chuyển",
  },
  {
    "logo": Icons.flight,
    "brand": "Traveloka",
    "desc": "Giảm 20% tối đa 100K cho lần đầu",
    "note": "Thanh toán qua web/app",
    "date": "30.09.2025",
    "category": "Du lịch",
  },
  {
    "logo": Icons.store,
    "brand": "LOTTE Mart",
    "desc": "Giảm 20% tối đa 50K cho lần đầu",
    "note": "Thanh toán qua web/app",
    "date": "30.09.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.local_activity,
    "brand": "CGV",
    "desc": "Giảm 15% vé xem phim",
    "note": "Thanh toán online",
    "date": "30.09.2025",
    "category": "Giải trí",
  },
  {
    "logo": Icons.fastfood,
    "brand": "KFC",
    "desc": "Mua 1 tặng 1 combo gà rán",
    "note": "Áp dụng tại cửa hàng",
    "date": "31.12.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.local_cafe,
    "brand": "Highlands Coffee",
    "desc": "Giảm 30% khi mua từ 2 ly trở lên",
    "note": "Áp dụng trên app",
    "date": "30.11.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.directions_car,
    "brand": "Grab",
    "desc": "Giảm 25% tối đa 50K cho chuyến đi",
    "note": "Thanh toán qua ví",
    "date": "31.10.2025",
    "category": "Di chuyển",
  },
  {
    "logo": Icons.shopping_cart,
    "brand": "Shopee",
    "desc": "Giảm 15% cho đơn từ 300K",
    "note": "Thanh toán qua ShopeePay",
    "date": "30.09.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.local_mall,
    "brand": "Lazada",
    "desc": "Giảm 50K cho đơn từ 250K",
    "note": "Áp dụng Lazada App",
    "date": "15.10.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.devices,
    "brand": "Tiki",
    "desc": "Giảm 20% khi mua đồ điện tử",
    "note": "Áp dụng trực tuyến",
    "date": "20.11.2025",
    "category": "Công nghệ",
  },
  {
    "logo": Icons.shopping_bag,
    "brand": "Vinmart",
    "desc": "Giảm 10% cho đơn hàng siêu thị",
    "note": "Áp dụng offline",
    "date": "30.09.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.sports_esports,
    "brand": "Garena",
    "desc": "Khuyến mãi nạp game 5%",
    "note": "Áp dụng qua app Garena",
    "date": "31.12.2025",
    "category": "Giải trí",
  },
  {
    "logo": Icons.hotel,
    "brand": "Agoda",
    "desc": "Giảm 15% cho booking khách sạn",
    "note": "Áp dụng trên app",
    "date": "30.12.2025",
    "category": "Du lịch",
  },
  {
    "logo": Icons.watch,
    "brand": "Apple Store",
    "desc": "Giảm 5% khi mua Apple Watch",
    "note": "Chỉ áp dụng online",
    "date": "31.12.2025",
    "category": "Công nghệ",
  },
  {
    "logo": Icons.computer,
    "brand": "FPT Shop",
    "desc": "Giảm 1 triệu cho laptop từ 15 triệu",
    "note": "Áp dụng trực tiếp tại cửa hàng",
    "date": "15.11.2025",
    "category": "Công nghệ",
  },
  {
    "logo": Icons.checkroom,
    "brand": "Canifa",
    "desc": "Giảm 20% bộ sưu tập Thu Đông",
    "note": "Áp dụng toàn quốc",
    "date": "30.10.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.shopping_basket,
    "brand": "H&M",
    "desc": "Giảm 15% cho đơn từ 500K",
    "note": "Chỉ áp dụng online",
    "date": "30.09.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.face_retouching_natural,
    "brand": "Guardian",
    "desc": "Mua 2 tặng 1 sản phẩm skincare",
    "note": "Áp dụng tại cửa hàng",
    "date": "31.12.2025",
    "category": "Sức khỏe",
  },
  {
    "logo": Icons.local_hospital,
    "brand": "Pharmacity",
    "desc": "Giảm 10% thuốc & vitamin",
    "note": "Áp dụng thành viên",
    "date": "31.12.2025",
    "category": "Sức khỏe",
  },
  {
    "logo": Icons.sports_soccer,
    "brand": "Decathlon",
    "desc": "Giảm 15% đồ thể thao",
    "note": "Áp dụng toàn quốc",
    "date": "15.11.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.pedal_bike,
    "brand": "The Coffee House",
    "desc": "Freeship cho đơn từ 2 ly",
    "note": "Đặt qua app",
    "date": "30.09.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.food_bank,
    "brand": "Baemin",
    "desc": "Giảm 40% cho đơn đầu tiên",
    "note": "Thanh toán qua ví",
    "date": "30.09.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.delivery_dining,
    "brand": "ShopeeFood",
    "desc": "Giảm 20K cho đơn từ 50K",
    "note": "Áp dụng toàn quốc",
    "date": "30.09.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.lunch_dining,
    "brand": "Phở 24",
    "desc": "Combo phở + nước chỉ 49K",
    "note": "Áp dụng tại cửa hàng",
    "date": "30.09.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.coffee,
    "brand": "Starbucks",
    "desc": "Giảm 20% khi mua từ 2 ly",
    "note": "Áp dụng toàn quốc",
    "date": "15.10.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.fastfood,
    "brand": "Burger King",
    "desc": "Mua 1 tặng 1 Whopper",
    "note": "Chỉ áp dụng thứ 6",
    "date": "31.12.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.local_bar,
    "brand": "Sapporo Beer",
    "desc": "Giảm 10% khi mua thùng 24 lon",
    "note": "Áp dụng trên app",
    "date": "30.11.2025",
    "category": "Ăn uống",
  },
  {
    "logo": Icons.directions_bus,
    "brand": "Xe khách Phương Trang",
    "desc": "Giảm 15% vé khứ hồi",
    "note": "Thanh toán qua ANPAY",
    "date": "31.12.2025",
    "category": "Di chuyển",
  },
  {
    "logo": Icons.train_outlined,
    "brand": "Metro Hà Nội",
    "desc": "Mua 5 vé tặng 1 vé",
    "note": "Áp dụng offline",
    "date": "30.09.2025",
    "category": "Di chuyển",
  },
  {
    "logo": Icons.directions_car,
    "brand": "BeCar",
    "desc": "Giảm 25% cho chuyến đầu tiên",
    "note": "Áp dụng tại Hà Nội/TP.HCM",
    "date": "31.12.2025",
    "category": "Di chuyển",
  },
  {
    "logo": Icons.local_movies,
    "brand": "Netflix",
    "desc": "1 tháng miễn phí gói Premium",
    "note": "Chỉ cho tài khoản mới",
    "date": "30.09.2025",
    "category": "Giải trí",
  },
  {
    "logo": Icons.computer,
    "brand": "Thế Giới Di Động",
    "desc": "Giảm 500K khi mua iPhone",
    "note": "Áp dụng online/offline",
    "date": "30.09.2025",
    "category": "Công nghệ",
  },
  {
    "logo": Icons.tv,
    "brand": "Điện Máy Xanh",
    "desc": "Giảm 10% TV Samsung",
    "note": "Áp dụng đơn từ 5 triệu",
    "date": "31.12.2025",
    "category": "Công nghệ",
  },
  {
    "logo": Icons.phone_android,
    "brand": "CellphoneS",
    "desc": "Giảm 15% phụ kiện điện thoại",
    "note": "Áp dụng toàn quốc",
    "date": "30.09.2025",
    "category": "Công nghệ",
  },
  {
    "logo": Icons.shopping_bag,
    "brand": "Uniqlo",
    "desc": "Giảm 200K cho đơn từ 1 triệu",
    "note": "Áp dụng app Uniqlo",
    "date": "31.10.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.checkroom,
    "brand": "Zara",
    "desc": "Giảm 20% bộ sưu tập mới",
    "note": "Áp dụng cửa hàng",
    "date": "15.11.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.hotel,
    "brand": "Vinpearl",
    "desc": "Giảm 30% phòng nghỉ",
    "note": "Áp dụng booking online",
    "date": "31.12.2025",
    "category": "Du lịch",
  },
  {
    "logo": Icons.beach_access,
    "brand": "Resort Đà Nẵng",
    "desc": "Combo 3N2Đ giảm 20%",
    "note": "Áp dụng khách đoàn",
    "date": "30.09.2025",
    "category": "Du lịch",
  },
  {
    "logo": Icons.airplane_ticket,
    "brand": "Vietnam Airlines",
    "desc": "Giảm 25% vé quốc tế",
    "note": "Áp dụng online",
    "date": "31.12.2025",
    "category": "Du lịch",
  },
  {
    "logo": Icons.local_hospital,
    "brand": "Bệnh viện Vinmec",
    "desc": "Giảm 10% khám tổng quát",
    "note": "Áp dụng bảo hiểm ANPAY",
    "date": "31.12.2025",
    "category": "Sức khỏe",
  },
  {
    "logo": Icons.medical_services,
    "brand": "Phòng khám Hòa Hảo",
    "desc": "Khám mắt miễn phí",
    "note": "Áp dụng cuối tuần",
    "date": "30.09.2025",
    "category": "Sức khỏe",
  },
  {
    "logo": Icons.fitness_center,
    "brand": "California Fitness",
    "desc": "Tặng 1 tháng tập thử",
    "note": "Đăng ký online",
    "date": "31.12.2025",
    "category": "Sức khỏe",
  },
  {
    "logo": Icons.book_online,
    "brand": "Coursera",
    "desc": "Giảm 30% khóa học online",
    "note": "Áp dụng thẻ ANPAY",
    "date": "31.12.2025",
    "category": "Giáo dục",
  },
  {
    "logo": Icons.school,
    "brand": "IELTS Fighter",
    "desc": "Voucher 1 triệu học phí",
    "note": "Áp dụng khóa offline",
    "date": "30.09.2025",
    "category": "Giáo dục",
  },
  {
    "logo": Icons.brush,
    "brand": "CG Art School",
    "desc": "Giảm 20% lớp học vẽ",
    "note": "Áp dụng học viên mới",
    "date": "31.10.2025",
    "category": "Giáo dục",
  },
  {
    "logo": Icons.shopping_cart,
    "brand": "Con Cưng",
    "desc": "Giảm 15% sản phẩm trẻ em",
    "note": "Áp dụng toàn quốc",
    "date": "30.09.2025",
    "category": "Mua sắm",
  },
  {
    "logo": Icons.pets,
    "brand": "PetMart",
    "desc": "Mua 2 tặng 1 thức ăn cho chó mèo",
    "note": "Áp dụng cửa hàng",
    "date": "31.12.2025",
    "category": "Mua sắm",
  },
];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // khi đổi tab thì lọc lại
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Hàm lọc danh sách ưu đãi
  List<Map<String, dynamic>> get filteredPromotions {
    // B1: lọc theo category
    var list = selectedCategory == "Tất cả"
        ? promotions
        : promotions.where((p) => p["category"] == selectedCategory).toList();

    // B2: nếu đang ở tab "Sắp hết hạn" thì lọc trong 15 ngày tới
    if (_tabController.index == 1) {
      final now = DateTime.now();
      final soon = now.add(const Duration(days: 20));

      list = list.where((p) {
        final parts = p["date"].toString().split(".");
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            final date = DateTime(year, month, day);
            return date.isAfter(now) && date.isBefore(soon);
          }
        }
        return false;
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mã Giảm Giá"),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: widget.showBackButton,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(text: "Mới nhất"),
            Tab(text: "Sắp hết hạn"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.red.shade50 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              isSelected ? Colors.purple : Colors.transparent),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                          color: isSelected ? Colors.purple : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Danh sách ưu đãi
          Expanded(
            child: ListView.builder(
              itemCount: filteredPromotions.length,
              itemBuilder: (context, index) {
                final item = filteredPromotions[index];
                return _promotionCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _promotionCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(item["logo"], color: Colors.purple),
        title: Text(item["brand"]),
        subtitle: Text("${item["desc"]}\nHSD: ${item["date"]}"),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text("Dùng ngay"),
        ),
      ),
    );
  }
}


