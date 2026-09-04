import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/notification/data/notification_repository.dart';
import 'package:app_do_an/navigator/navigator_widget/transaction_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCenterScreen extends StatefulWidget {
  final NotificationRepository? repository;

  const NotificationCenterScreen({super.key, this.repository});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 20;
  static const List<String> _categories = ['MY', 'BALANCE_CHANGE', 'NEWS'];

  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  String? _error;
  int _activeTab = 0;
  int _requestRevision = 0;

  String get _category => _categories[_activeTab];
  NotificationRepository get _repository =>
      widget.repository ?? AppServices.notification;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: _activeTab,
    );
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);
    _reload();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final next = _tabController.index;
    if (next == _activeTab) return;
    setState(() => _activeTab = next);
    _reload();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _loading ||
        _loadingMore ||
        !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 320) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    final category = _category;
    final requestRevision = ++_requestRevision;
    AppLogger.repo('NOTIFICATION_UI', 'Reload notifications', {
      'category': category,
    });
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      _page = 0;
      _hasMore = true;
      _items = const [];
    });

    try {
      final result = await _repository.list(
        page: 0,
        size: _pageSize,
        category: category,
      );
      if (!_isCurrentRequest(requestRevision, category)) return;
      final items = _itemsForCategory(result.items, category);
      setState(() {
        _items = items;
        _page = 0;
        _hasMore = result.hasMore;
      });
    } on ApiException catch (e) {
      if (_isCurrentRequest(requestRevision, category)) {
        setState(() => _error = e.message);
      }
    } finally {
      if (_isCurrentRequest(requestRevision, category)) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final category = _category;
    final requestRevision = _requestRevision;
    final nextPage = _page + 1;
    setState(() => _loadingMore = true);
    try {
      final result = await _repository.list(
        page: nextPage,
        size: _pageSize,
        category: category,
      );
      if (!_isCurrentRequest(requestRevision, category)) return;
      final knownIds = _items.map((item) => item['id']?.toString()).toSet();
      final extra = _itemsForCategory(
        result.items,
        category,
      ).where((item) => !knownIds.contains(item['id']?.toString())).toList();
      setState(() {
        _items = [..._items, ...extra];
        _page = nextPage;
        _hasMore = result.hasMore;
      });
    } on ApiException catch (e) {
      if (_isCurrentRequest(requestRevision, category)) _show(e.message);
    } finally {
      if (_isCurrentRequest(requestRevision, category)) {
        setState(() => _loadingMore = false);
      }
    }
  }

  bool _isCurrentRequest(int requestRevision, String category) {
    return mounted &&
        requestRevision == _requestRevision &&
        category == _category;
  }

  List<Map<String, dynamic>> _itemsForCategory(
    List<Map<String, dynamic>> items,
    String category,
  ) {
    return items
        .where((item) {
          final itemCategory = item['category']
              ?.toString()
              .trim()
              .toUpperCase();
          return !_categories.contains(itemCategory) ||
              itemCategory == category;
        })
        .toList(growable: false);
  }

  bool _isUnread(Map<String, dynamic> item) {
    if (item['read'] is bool) return item['read'] == false;
    return item['readAt'] == null;
  }

  Future<void> _readAll() async {
    final category = _category;
    final requestRevision = _requestRevision;
    AppLogger.action('NOTIFICATION mark current category read', {
      'category': category,
    });
    try {
      await _repository.readAll(category: category);
      if (!_isCurrentRequest(requestRevision, category)) return;
      final now = DateTime.now().toUtc().toIso8601String();
      setState(() {
        _items = _items
            .map(
              (item) => {
                ...item,
                'read': true,
                'readAt': item['readAt'] ?? now,
              },
            )
            .toList();
      });
    } on ApiException catch (e) {
      _show(e.message);
    }
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final id = item['id']?.toString();
    AppLogger.action('NOTIFICATION item pressed', {
      'id': AppLogger.mask(id),
      'type': item['type']?.toString(),
      'category': item['category']?.toString(),
    });

    if (id != null && _isUnread(item)) {
      try {
        await _repository.read(id);
        if (mounted) {
          final now = DateTime.now().toUtc().toIso8601String();
          setState(() {
            final index = _items.indexWhere(
              (value) => value['id']?.toString() == id,
            );
            if (index >= 0) {
              final updated = [..._items];
              updated[index] = {...updated[index], 'read': true, 'readAt': now};
              _items = updated;
            }
          });
        }
      } on ApiException catch (e) {
        _show(e.message);
      }
    }

    if (!mounted) return;
    final transactionId = item['relatedTransactionId']?.toString();
    if (transactionId != null && transactionId.isNotEmpty) {
      await showTransactionDetailSheet(context, transactionId: transactionId);
      return;
    }
    await _showNotificationDetail(item);
  }

  Future<void> _showNotificationDetail(Map<String, dynamic> item) {
    final createdAt = DateTime.tryParse(
      item['createdAt']?.toString() ?? '',
    )?.toLocal();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item['title']?.toString() ?? 'Thông báo',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item['body']?.toString() ?? '',
                  style: const TextStyle(fontSize: 15, height: 1.45),
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    DateFormat('HH:mm · dd/MM/yyyy').format(createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<_NotificationEntry> _entries() {
    final entries = <_NotificationEntry>[];
    String? lastDate;
    for (final item in _items) {
      final createdAt = DateTime.tryParse(
        item['createdAt']?.toString() ?? '',
      )?.toLocal();
      final date = createdAt == null
          ? 'Không rõ ngày'
          : DateFormat('dd/MM/yyyy').format(createdAt);
      if (date != lastDate) {
        entries.add(_NotificationEntry.header(date));
        lastDate = date;
      }
      entries.add(_NotificationEntry.item(item));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Đánh dấu tab này đã đọc',
            onPressed: _items.any(_isUnread) ? _readAll : null,
            icon: const Icon(Icons.done_all),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.grey.shade700,
          indicatorColor: Colors.purple,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Của tôi'),
            Tab(text: 'Biến động số dư'),
            Tab(text: 'Bảng tin'),
          ],
        ),
      ),
      body: RefreshIndicator(onRefresh: _reload, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 260),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null && _items.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 210),
          const Icon(Icons.cloud_off_outlined, size: 52, color: Colors.grey),
          const SizedBox(height: 12),
          const Center(child: Text('Không tải được thông báo')),
          const SizedBox(height: 6),
          Center(child: Text(_error!, textAlign: TextAlign.center)),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: _reload,
              child: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 190),
          Icon(
            _category == 'BALANCE_CHANGE'
                ? Icons.account_balance_wallet_outlined
                : _category == 'NEWS'
                ? Icons.campaign_outlined
                : Icons.notifications_none,
            size: 64,
            color: Colors.purple.shade200,
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _category == 'BALANCE_CHANGE'
                  ? 'Chưa có biến động số dư trong 90 ngày gần đây'
                  : _category == 'NEWS'
                  ? 'Chưa có bảng tin mới'
                  : 'Chưa có thông báo cá nhân',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      );
    }

    final entries = _entries();
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: entries.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          return const Padding(
            padding: EdgeInsets.all(18),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final entry = entries[index];
        if (entry.date != null) return _dateHeader(entry.date!);
        return _notificationCard(entry.data!);
      },
    );
  }

  Widget _dateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Text(
        date,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final unread = _isUnread(item);
    final createdAt = DateTime.tryParse(
      item['createdAt']?.toString() ?? '',
    )?.toLocal();
    final amount = (item['amount'] as num?)?.toInt();
    final balanceAfter = (item['balanceAfter'] as num?)?.toInt();
    final direction = item['direction']?.toString().toUpperCase() ?? '';
    final incoming = direction == 'IN';
    final isBalance = item['category']?.toString() == 'BALANCE_CHANGE';

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 0,
      color: unread
          ? Colors.purple.shade50.withValues(alpha: 0.55)
          : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: unread ? Colors.purple.shade100 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openNotification(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isBalance
                      ? (incoming ? Colors.green.shade50 : Colors.red.shade50)
                      : Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBalance
                      ? (incoming ? Icons.south_west : Icons.north_east)
                      : item['category']?.toString() == 'NEWS'
                      ? Icons.campaign_outlined
                      : Icons.notifications_outlined,
                  color: isBalance
                      ? (incoming ? Colors.green.shade700 : Colors.red.shade700)
                      : Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item['title']?.toString() ?? 'Thông báo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5, left: 8),
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (amount != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${incoming ? '+' : '-'}${NumberFormat('#,###', 'vi_VN').format(amount)} ₫',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: incoming
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      item['body']?.toString() ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (balanceAfter != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Số dư sau giao dịch: ${NumberFormat('#,###', 'vi_VN').format(balanceAfter)} ₫',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (createdAt != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        DateFormat('HH:mm').format(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationEntry {
  final String? date;
  final Map<String, dynamic>? data;

  const _NotificationEntry._({this.date, this.data});

  factory _NotificationEntry.header(String date) =>
      _NotificationEntry._(date: date);

  factory _NotificationEntry.item(Map<String, dynamic> data) =>
      _NotificationEntry._(data: data);
}
