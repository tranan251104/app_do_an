import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/model/promotion.dart';
import 'package:app_do_an/navigator/service/partner_link_service.dart';
import 'package:app_do_an/navigator/service/promotion_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopUpTabbar extends StatefulWidget {
  final bool showBackButton;
  final PromotionRepository? repository;

  const TopUpTabbar({super.key, this.showBackButton = false, this.repository});

  @override
  State<TopUpTabbar> createState() => _TopUpTabbarState();
}

class _TopUpTabbarState extends State<TopUpTabbar>
    with SingleTickerProviderStateMixin {
  static const List<String> _categories = [
    'Tất cả',
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Công nghệ',
    'Du lịch',
    'Sức khỏe',
    'Giáo dục',
    'Giải trí',
  ];

  late final TabController _tabController;
  late final PromotionRepository _repository;

  List<Promotion> _promotions = const [];
  String _selectedCategory = 'Tất cả';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? BackendPromotionRepository();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    AppLogger.repo('PROMOTION_UI', 'Load promotions');
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final promotions = await _repository.fetchPromotions();
      if (!mounted) return;
      setState(() {
        _promotions = promotions;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách ưu đãi';
      });
    }
  }

  void _handleTabChanged() {
    AppLogger.action('PROMOTION tab changed', {'index': _tabController.index});
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {});
    }
  }

  List<Promotion> get _filteredPromotions {
    final now = DateTime.now();
    final promotions = _promotions.where((promotion) {
      final matchesCategory =
          _selectedCategory == 'Tất cả' ||
          promotion.category == _selectedCategory;
      if (!matchesCategory || !promotion.isActiveAt(now)) return false;

      return _tabController.index == 0 || promotion.isExpiringSoonAt(now);
    }).toList();

    if (_tabController.index == 0) {
      promotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      promotions.sort((a, b) => a.validUntil.compareTo(b.validUntil));
    }

    return promotions;
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã Giảm Giá'),
        backgroundColor: Colors.purple,
        automaticallyImplyLeading: widget.showBackButton,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(text: 'Mới nhất'),
            Tab(text: 'Sắp hết hạn'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildPromotionList()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: Colors.red.shade50,
              side: BorderSide(
                color: isSelected ? Colors.purple : Colors.transparent,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.purple : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPromotionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadPromotions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final promotions = _filteredPromotions;
    if (promotions.isEmpty) {
      return const Center(child: Text('Không có ưu đãi phù hợp'));
    }

    return RefreshIndicator(
      onRefresh: _loadPromotions,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 12),
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          return _promotionCard(promotions[index]);
        },
      ),
    );
  }

  Widget _promotionCard(Promotion promotion) {
    final now = DateTime.now();
    final remainingDays = promotion.remainingDaysAt(now);
    final expiryDate = DateFormat('dd.MM.yyyy').format(promotion.validUntil);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: ListTile(
        leading: Icon(_iconFor(promotion.iconKey), color: Colors.purple),
        title: Text(promotion.brand),
        subtitle: Text(
          '${promotion.description}\n'
          'HSD: $expiryDate · Còn $remainingDays ngày',
        ),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () => _usePromotion(promotion),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Dùng ngay'),
        ),
      ),
    );
  }

  Future<void> _usePromotion(Promotion promotion) async {
    AppLogger.action('PROMOTION use pressed', {'brand': promotion.brand});
    final opened = await PartnerLinkService.open(promotion.brand);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể mở trang ${promotion.brand}. Vui lòng thử lại.',
          ),
        ),
      );
    }
  }

  IconData _iconFor(String iconKey) {
    return switch (iconKey) {
      'train' => Icons.train,
      'flight' => Icons.flight,
      'store' => Icons.store,
      'ticket' => Icons.local_activity,
      'fastfood' => Icons.fastfood,
      'cafe' => Icons.local_cafe,
      'car' => Icons.directions_car,
      'cart' => Icons.shopping_cart,
      'mall' => Icons.local_mall,
      'devices' => Icons.devices,
      'shopping_bag' => Icons.shopping_bag,
      'game' => Icons.sports_esports,
      'hotel' => Icons.hotel,
      'watch' => Icons.watch,
      'computer' => Icons.computer,
      'fashion' => Icons.checkroom,
      'basket' => Icons.shopping_basket,
      'beauty' => Icons.face_retouching_natural,
      'hospital' => Icons.local_hospital,
      'sport' => Icons.sports_soccer,
      'coffee' => Icons.coffee,
      'food' => Icons.food_bank,
      'delivery' => Icons.delivery_dining,
      'bar' => Icons.local_bar,
      'bus' => Icons.directions_bus,
      'movie' => Icons.local_movies,
      'tv' => Icons.tv,
      'phone' => Icons.phone_android,
      'beach' => Icons.beach_access,
      'flight_ticket' => Icons.airplane_ticket,
      'medical' => Icons.medical_services,
      'fitness' => Icons.fitness_center,
      'book' => Icons.book_online,
      'school' => Icons.school,
      'brush' => Icons.brush,
      'pets' => Icons.pets,
      _ => Icons.local_offer,
    };
  }
}
