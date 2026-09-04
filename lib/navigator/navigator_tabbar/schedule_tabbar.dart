import 'dart:async';

import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/navigator_widget/transaction_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleTabbar extends StatefulWidget {
  const ScheduleTabbar({super.key});

  @override
  State<ScheduleTabbar> createState() => ScheduleTabbarState();
}

class ScheduleTabbarState extends State<ScheduleTabbar> {
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<Map<String, dynamic>> _transactions = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 0;
  String? _error;

  String _type = 'ALL';
  String _direction = 'ALL';
  String _status = 'ALL';
  String _period = '30D';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    loadTransactions();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refreshFromOutside() => loadTransactions();

  void _handleScroll() {
    if (!_scrollController.hasClients || _loading || _loadingMore || !_hasMore) {
      return;
    }
    if (_scrollController.position.extentAfter < 320) {
      _loadMore();
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) loadTransactions();
    });
  }

  DateTimeRange _periodRange() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    if (_period == 'CUSTOM' && _customRange != null) {
      final startDate = _customRange!.start;
      final endDate = _customRange!.end;
      return DateTimeRange(
        start: DateTime(startDate.year, startDate.month, startDate.day),
        end: DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999),
      );
    }

    final days = switch (_period) {
      '7D' => 7,
      '90D' => 90,
      '180D' => 180,
      '365D' => 365,
      _ => 30,
    };
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange? _exactDateFromSearch(String query) {
    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(query.trim());
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return DateTimeRange(
      start: DateTime(year, month, day),
      end: DateTime(year, month, day, 23, 59, 59, 999),
    );
  }

  ({String? keyword, DateTime from, DateTime to}) _queryWindow() {
    final raw = _searchController.text.trim();
    final exactDate = _exactDateFromSearch(raw);
    final range = exactDate ?? _periodRange();
    return (
      keyword: exactDate == null && raw.isNotEmpty ? raw : null,
      from: range.start,
      to: range.end,
    );
  }

  Future<void> loadTransactions() async {
    final window = _queryWindow();
    AppLogger.repo('TRANSACTION_UI', 'Reload transaction history', {
      'type': _type,
      'direction': _direction,
      'status': _status,
      'period': _period,
      'keyword': window.keyword,
      'from': window.from.toIso8601String(),
      'to': window.to.toIso8601String(),
    });

    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      _page = 0;
      _hasMore = true;
      _transactions = const [];
    });

    try {
      final result = await AppServices.transaction.list(
        page: 0,
        size: _pageSize,
        type: _type,
        direction: _direction,
        status: _status,
        keyword: window.keyword,
        from: window.from,
        to: window.to,
      );
      if (!mounted) return;
      setState(() {
        _transactions = result.items;
        _page = 0;
        _hasMore = result.hasMore;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final window = _queryWindow();
    final nextPage = _page + 1;
    setState(() => _loadingMore = true);
    try {
      final result = await AppServices.transaction.list(
        page: nextPage,
        size: _pageSize,
        type: _type,
        direction: _direction,
        status: _status,
        keyword: window.keyword,
        from: window.from,
        to: window.to,
      );
      if (!mounted) return;
      final knownIds = _transactions.map((item) => item['id']?.toString()).toSet();
      final extra = result.items
          .where((item) => !knownIds.contains(item['id']?.toString()))
          .toList();
      setState(() {
        _transactions = [..._transactions, ...extra];
        _page = nextPage;
        _hasMore = result.hasMore;
      });
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openFilters() async {
    var draftType = _type;
    var draftDirection = _direction;
    var draftStatus = _status;
    var draftPeriod = _period;
    var draftCustom = _customRange;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> chooseCustomDate() async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 10),
              lastDate: now,
              initialDateRange: draftCustom ??
                  DateTimeRange(
                    start: now.subtract(const Duration(days: 29)),
                    end: now,
                  ),
              helpText: 'Chọn khoảng tra cứu',
              saveText: 'Chọn',
            );
            if (picked == null) return;
            final days = picked.end.difference(picked.start).inDays + 1;
            if (days > 366) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mỗi lần tra cứu tối đa 366 ngày'),
                ),
              );
              return;
            }
            setSheetState(() {
              draftPeriod = 'CUSTOM';
              draftCustom = picked;
            });
          }

          return SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.88,
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            'Lọc giao dịch',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _filterTitle('Dòng tiền'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _choiceChip('Tất cả', 'ALL', draftDirection,
                                    (value) => setSheetState(() => draftDirection = value)),
                                _choiceChip('Tiền vào', 'IN', draftDirection,
                                    (value) => setSheetState(() => draftDirection = value)),
                                _choiceChip('Tiền ra', 'OUT', draftDirection,
                                    (value) => setSheetState(() => draftDirection = value)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _filterTitle('Loại giao dịch'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _choiceChip('Tất cả', 'ALL', draftType,
                                    (value) => setSheetState(() => draftType = value)),
                                _choiceChip('Chuyển AnPay', 'INTERNAL_TRANSFER', draftType,
                                    (value) => setSheetState(() => draftType = value)),
                                _choiceChip('Chuyển ngân hàng', 'EXTERNAL_BANK_TRANSFER', draftType,
                                    (value) => setSheetState(() => draftType = value)),
                                _choiceChip('Nạp tiền', 'TOP_UP', draftType,
                                    (value) => setSheetState(() => draftType = value)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _filterTitle('Trạng thái'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _choiceChip('Tất cả', 'ALL', draftStatus,
                                    (value) => setSheetState(() => draftStatus = value)),
                                _choiceChip('Thành công', 'COMPLETED', draftStatus,
                                    (value) => setSheetState(() => draftStatus = value)),
                                _choiceChip('Đang xử lý', 'PENDING', draftStatus,
                                    (value) => setSheetState(() => draftStatus = value)),
                                _choiceChip('Thất bại', 'FAILED', draftStatus,
                                    (value) => setSheetState(() => draftStatus = value)),
                                _choiceChip('Đã hủy', 'CANCELLED', draftStatus,
                                    (value) => setSheetState(() => draftStatus = value)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _filterTitle('Thời gian'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _choiceChip('7 ngày', '7D', draftPeriod,
                                    (value) => setSheetState(() => draftPeriod = value)),
                                _choiceChip('30 ngày', '30D', draftPeriod,
                                    (value) => setSheetState(() => draftPeriod = value)),
                                _choiceChip('3 tháng', '90D', draftPeriod,
                                    (value) => setSheetState(() => draftPeriod = value)),
                                _choiceChip('6 tháng', '180D', draftPeriod,
                                    (value) => setSheetState(() => draftPeriod = value)),
                                _choiceChip('1 năm', '365D', draftPeriod,
                                    (value) => setSheetState(() => draftPeriod = value)),
                                ChoiceChip(
                                  label: Text(
                                    draftPeriod == 'CUSTOM' && draftCustom != null
                                        ? '${DateFormat('dd/MM/yyyy').format(draftCustom!.start)} - ${DateFormat('dd/MM/yyyy').format(draftCustom!.end)}'
                                        : 'Tùy chọn',
                                  ),
                                  selected: draftPeriod == 'CUSTOM',
                                  selectedColor: Colors.purple.shade100,
                                  onSelected: (_) => chooseCustomDate(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  draftType = 'ALL';
                                  draftDirection = 'ALL';
                                  draftStatus = 'ALL';
                                  draftPeriod = '30D';
                                  draftCustom = null;
                                });
                              },
                              child: const Text('Đặt lại'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(sheetContext, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Áp dụng'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (applied != true || !mounted) return;
    setState(() {
      _type = draftType;
      _direction = draftDirection;
      _status = draftStatus;
      _period = draftPeriod;
      _customRange = draftCustom;
    });
    loadTransactions();
  }

  Widget _filterTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _choiceChip(
    String label,
    String value,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: value == selected,
      selectedColor: Colors.purple.shade100,
      onSelected: (_) => onSelected(value),
    );
  }

  bool get _hasCustomFilters =>
      _type != 'ALL' ||
      _direction != 'ALL' ||
      _status != 'ALL' ||
      _period != '30D';

  String _periodLabel() {
    if (_period == 'CUSTOM' && _customRange != null) {
      return '${DateFormat('dd/MM/yyyy').format(_customRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_customRange!.end)}';
    }
    return switch (_period) {
      '7D' => '7 ngày',
      '90D' => '3 tháng',
      '180D' => '6 tháng',
      '365D' => '1 năm',
      _ => '30 ngày',
    };
  }

  List<_HistoryEntry> _entries() {
    final result = <_HistoryEntry>[];
    String? lastDate;
    for (final tx in _transactions) {
      final createdAt = DateTime.tryParse(tx['createdAt']?.toString() ?? '')?.toLocal();
      final date = createdAt == null
          ? 'Không rõ ngày'
          : DateFormat('dd/MM/yyyy').format(createdAt);
      if (date != lastDate) {
        result.add(_HistoryEntry.header(date));
        lastDate = date;
      }
      result.add(_HistoryEntry.item(tx));
    }
    return result;
  }

  Future<void> _openTransaction(Map<String, dynamic> tx) async {
    final id = tx['id']?.toString();
    if (id == null || id.isEmpty) return;
    await showTransactionDetailSheet(
      context,
      transactionId: id,
      initialData: tx,
    );
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Tên, số ANP, ngân hàng, mã GD hoặc dd/MM/yyyy',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                    loadTransactions();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton.filledTonal(
                          tooltip: 'Bộ lọc',
                          onPressed: _openFilters,
                          icon: const Icon(Icons.tune),
                        ),
                        if (_hasCustomFilters)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 5),
                    Text(
                      'Phạm vi: ${_periodLabel()}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    if (_transactions.isNotEmpty)
                      Text(
                        '${_transactions.length}${_hasMore ? '+' : ''} giao dịch',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadTransactions,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 250),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null && _transactions.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 190),
          const Icon(Icons.cloud_off_outlined, size: 54, color: Colors.grey),
          const SizedBox(height: 12),
          const Center(child: Text('Không tải được lịch sử giao dịch')),
          const SizedBox(height: 6),
          Center(child: Text(_error!, textAlign: TextAlign.center)),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: loadTransactions,
              child: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    if (_transactions.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 190),
          Icon(Icons.receipt_long_outlined, size: 66, color: Colors.purple.shade200),
          const SizedBox(height: 14),
          const Center(child: Text('Không tìm thấy giao dịch phù hợp')),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'Thử đổi từ khóa, bộ lọc hoặc khoảng thời gian.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      );
    }

    final entries = _entries();
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
      itemCount: entries.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= entries.length) {
          return const Padding(
            padding: EdgeInsets.all(18),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final entry = entries[index];
        if (entry.date != null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 15, 4, 8),
            child: Text(
              entry.date!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          );
        }
        return _transactionCard(entry.data!);
      },
    );
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num?)?.toInt() ?? 0;
    final direction = tx['direction']?.toString().toUpperCase() ?? '';
    final incoming = direction == 'IN' || direction == 'CREDIT';
    final createdAt = DateTime.tryParse(tx['createdAt']?.toString() ?? '')?.toLocal();
    final title = tx['title']?.toString() ?? _fallbackTitle(tx);
    final counterpartyName = tx['counterpartyName']?.toString();
    final counterpartyAccount = tx['counterpartyAccount']?.toString();
    final bankName = tx['bankName']?.toString();
    final status = tx['status']?.toString() ?? '';

    final subtitleParts = <String>[
      if (counterpartyName != null && counterpartyName.isNotEmpty) counterpartyName,
      if (bankName != null && bankName.isNotEmpty) bankName,
      if (counterpartyAccount != null && counterpartyAccount.isNotEmpty) counterpartyAccount,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openTransaction(tx),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: incoming ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  incoming ? Icons.south_west : Icons.north_east,
                  color: incoming ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitleParts.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (createdAt != null)
                          Text(
                            DateFormat('HH:mm').format(createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        if (createdAt != null) const SizedBox(width: 8),
                        Text(
                          _statusLabel(status),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _statusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${incoming ? '+' : '-'}${NumberFormat('#,###', 'vi_VN').format(amount)} ₫',
                style: TextStyle(
                  color: incoming ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fallbackTitle(Map<String, dynamic> tx) {
    final type = tx['type']?.toString() ?? '';
    final direction = tx['direction']?.toString().toUpperCase() ?? '';
    if (type == 'INTERNAL_TRANSFER') {
      return direction == 'IN' ? 'Nhận tiền' : 'Chuyển tiền';
    }
    if (type == 'EXTERNAL_BANK_TRANSFER') return 'Chuyển ngân hàng';
    if (type == 'TOP_UP') return 'Nạp tiền';
    return 'Giao dịch AnPay';
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Thành công';
      case 'PENDING':
      case 'OTP_REQUIRED':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      case 'CANCELLED':
      case 'CANCELED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green.shade700;
      case 'PENDING':
      case 'OTP_REQUIRED':
        return Colors.orange.shade700;
      case 'FAILED':
      case 'CANCELLED':
      case 'CANCELED':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}

class _HistoryEntry {
  final String? date;
  final Map<String, dynamic>? data;

  const _HistoryEntry._({this.date, this.data});

  factory _HistoryEntry.header(String date) => _HistoryEntry._(date: date);

  factory _HistoryEntry.item(Map<String, dynamic> data) =>
      _HistoryEntry._(data: data);
}
