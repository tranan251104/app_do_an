import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/features/transaction/data/transaction_summary.dart';
import 'package:app_do_an/navigator/navigator_widget/transaction_detail_sheet.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionStatisticsScreen extends StatefulWidget {
  const TransactionStatisticsScreen({super.key});
  @override
  State<TransactionStatisticsScreen> createState() =>
      _TransactionStatisticsScreenState();
}

class _TransactionStatisticsScreenState
    extends State<TransactionStatisticsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  TransactionSummary? _summary;
  bool _loading = true;
  String? _error;
  int _request = 0;
  final _money = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    final month = _month;
    setState(() {
      _loading = true;
      _error = null;
      _summary = null;
    });
    try {
      final transactions = <Map<String, dynamic>>[];
      final ids = <String>{};
      var page = 0;
      while (true) {
        final result = await AppServices.transaction.list(
          page: page,
          size: 100,
          status: 'COMPLETED',
          from: month,
          to: DateTime(
            month.year,
            month.month + 1,
          ).subtract(const Duration(microseconds: 1)),
        );
        if (!mounted || request != _request) return;
        if (result.page != page || (result.items.isEmpty && result.hasMore)) {
          throw StateError('Invalid pagination');
        }
        for (final tx in result.items) {
          final id = tx['id']?.toString();
          if (id == null || ids.add(id)) transactions.add(tx);
        }
        if (!result.hasMore) break;
        page++;
      }
      setState(() => _summary = TransactionSummary(transactions, month));
    } catch (_) {
      if (mounted && request == _request) {
        setState(
          () => _error = 'Không tải đủ dữ liệu thống kê. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  void _changeMonth(int offset) {
    setState(() => _month = DateTime(_month.year, _month.month + offset));
    _load();
  }

  void _openGroup(String name, List<Map<String, dynamic>> transactions) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(TransactionSummary.typeLabel(name))),
          body: ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final incoming = TransactionSummary.incoming(tx);
              final id = tx['id']?.toString();
              return ListTile(
                leading: Icon(
                  incoming ? Icons.south_west : Icons.north_east,
                  color: incoming ? Colors.green : Colors.deepOrange,
                ),
                title: Text(
                  tx['counterpartyName']?.toString() ??
                      tx['title']?.toString() ??
                      TransactionSummary.typeLabel(name),
                ),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(
                    DateTime.parse(tx['createdAt'].toString()).toLocal(),
                  ),
                ),
                trailing: Text(
                  '${incoming ? '+' : '-'}${_money.format(TransactionSummary.amount(tx))}',
                ),
                onTap: id == null || id.isEmpty
                    ? null
                    : () => showTransactionDetailSheet(
                        context,
                        transactionId: id,
                        initialData: tx,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê thu – chi')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Tháng trước',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('MM/yyyy').format(_month),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  tooltip: 'Tháng sau',
                  onPressed:
                      _month.year == now.year && _month.month == now.month
                      ? null
                      : () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null) ...[
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: _load, child: const Text('Thử lại')),
            ] else if (summary != null) ...[
              _totalCard('Tiền vào', summary.income, Colors.green),
              _totalCard('Tiền ra', summary.expense, Colors.deepOrange),
              _totalCard(
                'Chênh lệch',
                summary.income - summary.expense,
                Colors.purple,
              ),
              const SizedBox(height: 12),
              const Text(
                'Chỉ tính số tiền của giao dịch thành công; không cộng thêm phí. Khoản nạp/chuyển vào ví cũng được tính là tiền vào.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              if (summary.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Tháng này chưa có giao dịch thành công.',
                    textAlign: TextAlign.center,
                  ),
                )
              else ...[
                const Text(
                  'Theo ngày',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text(
                  'Xanh: tiền vào · Cam: tiền ra',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minX: 1,
                      maxX: DateTime(
                        _month.year,
                        _month.month + 1,
                        0,
                      ).day.toDouble(),
                      minY: 0,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 54,
                            getTitlesWidget: (value, meta) => Text(
                              NumberFormat.compact(locale: 'vi').format(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            reservedSize: 28,
                          ),
                        ),
                      ),
                      lineBarsData: [
                        for (final incoming in [true, false])
                          LineChartBarData(
                            spots: [
                              for (
                                var day = 1;
                                day <=
                                    DateTime(
                                      _month.year,
                                      _month.month + 1,
                                      0,
                                    ).day;
                                day++
                              )
                                FlSpot(
                                  day.toDouble(),
                                  summary.daily(day, incoming),
                                ),
                            ],
                            color: incoming ? Colors.green : Colors.deepOrange,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nhóm giao dịch',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                for (final group in summary.groups.entries)
                  Card(
                    child: ListTile(
                      title: Text(TransactionSummary.typeLabel(group.key)),
                      subtitle: Text(
                        '${group.value.length} giao dịch · ${_money.format(group.value.fold<double>(0, (sum, tx) => sum + TransactionSummary.amount(tx)))}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openGroup(group.key, group.value),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _totalCard(String label, double value, Color color) => Card(
    color: color.withValues(alpha: .08),
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Text(
            _money.format(value),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
