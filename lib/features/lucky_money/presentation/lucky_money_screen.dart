import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/paged_result.dart';
import '../data/lucky_money_repository.dart';
import 'lucky_money_create_screen.dart';
import 'lucky_money_detail_screen.dart';
import 'lucky_money_widgets.dart';

class LuckyMoneyScreen extends StatefulWidget {
  final LuckyMoneyRepository? repository;
  const LuckyMoneyScreen({super.key, this.repository});
  @override
  State<LuckyMoneyScreen> createState() => _LuckyMoneyScreenState();
}

class _LuckyMoneyScreenState extends State<LuckyMoneyScreen> {
  LuckyMoneyRepository get _repo => widget.repository ?? AppServices.luckyMoney;
  String _box = 'received';
  final List<LuckyEnvelope> _items = [];
  PagedResult<LuckyEnvelope>? _page;
  bool _loading = true;
  String? _error;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    final request = ++_request;
    final box = _box;
    final page = more ? (_page?.page ?? -1) + 1 : 0;
    setState(() {
      _loading = true;
      _error = null;
      if (!more) {
        _items.clear();
        _page = null;
      }
    });
    try {
      final result = await _repo.list(box: box, page: page);
      if (!mounted || request != _request) return;
      setState(() {
        _items.addAll(result.items);
        _page = result;
      });
    } catch (error) {
      if (mounted && request == _request) {
        setState(
          () => _error = error is ApiException
              ? error.message
              : 'Không tải được hộp lì xì. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LuckyMoneyCreateScreen(repository: _repo),
      ),
    );
    if (!mounted) return;
    setState(() => _box = 'sent');
    await _load();
  }

  Future<void> _detail(LuckyEnvelope e) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LuckyMoneyDetailScreen(envelopeId: e.id, repository: _repo),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Lì xì cá nhân'),
      leading: BackButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/tabbar');
          }
        },
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              const EnvelopeCard(
                template: 'PROSPERITY',
                greeting: 'Trao lời chúc, gửi may mắn đến người thương.',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.add),
                  label: const Text('Gửi lì xì'),
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'received',
              label: Text('Đã nhận'),
              icon: Icon(Icons.mark_email_unread_outlined),
            ),
            ButtonSegment(
              value: 'sent',
              label: Text('Đã gửi'),
              icon: Icon(Icons.outgoing_mail),
            ),
          ],
          selected: {_box},
          onSelectionChanged: (value) {
            setState(() => _box = value.first);
            _load();
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null) ...[
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => _load(more: _items.isNotEmpty),
                    child: const Text('Thử lại'),
                  ),
                ],
                if (!_loading && _error == null && _items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _box == 'sent'
                          ? 'Bạn chưa gửi phong bao nào. Gửi lời chúc đầu tiên ngay nhé!'
                          : 'Chưa có phong bao nào. Lì xì mới sẽ xuất hiện tại đây.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final e in _items)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            (envelopeTemplates[e.template] ??
                                    envelopeTemplates.values.first)
                                .$2,
                        child: const Icon(
                          Icons.card_giftcard,
                          color: Color(0xFFFFD77A),
                        ),
                      ),
                      title: Text(e.isSender ? e.receiverName : e.senderName),
                      subtitle: Text(
                        '${e.statusLabel}\n${e.isSender ? e.receiverWalletCode : e.senderWalletCode}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        e.amount == null ? 'Mở xem' : luckyAmount(e.amount!),
                      ),
                      onTap: () => _detail(e),
                    ),
                  ),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (!_loading && _page?.hasMore == true)
                  TextButton(
                    onPressed: () => _load(more: true),
                    child: const Text('Xem thêm'),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
