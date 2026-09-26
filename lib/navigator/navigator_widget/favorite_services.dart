import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String normalizeServiceQuery(String value) {
  var result = value.toLowerCase().trim();
  const groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  for (final entry in groups.entries) {
    for (final character in entry.value.split('')) {
      result = result.replaceAll(character, entry.key);
    }
  }
  return result;
}

class FavoriteServices extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onOpen;
  const FavoriteServices({
    super.key,
    required this.items,
    required this.onOpen,
  });

  @override
  State<FavoriteServices> createState() => _FavoriteServicesState();
}

class _FavoriteServicesState extends State<FavoriteServices> {
  static const storageKey = 'anpay.favorite-services.v1';
  List<String> _favorites = [];
  String _query = '';
  bool _ready = false;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(storageKey) ?? <String>[];
      if (!mounted) return;
      setState(() {
        _favorites = saved
            .where((label) => widget.items.any((e) => e['label'] == label))
            .toSet()
            .take(8)
            .toList();
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _edit() async {
    final draft = [..._favorites];
    final saved = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          return FractionallySizedBox(
            heightFactor: .85,
            child: Column(
              children: [
                ListTile(
                  title: Text('Dịch vụ yêu thích (${draft.length}/8)'),
                  subtitle: const Text(
                    'Nhấn giữ để sắp xếp. Lưu trên thiết bị này.',
                  ),
                  trailing: TextButton(
                    onPressed: () => Navigator.pop(context, draft),
                    child: const Text('Lưu'),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: draft.length,
                        onReorder: (oldIndex, newIndex) => update(() {
                          if (newIndex > oldIndex) newIndex--;
                          draft.insert(newIndex, draft.removeAt(oldIndex));
                        }),
                        itemBuilder: (context, index) => ListTile(
                          key: ValueKey(draft[index]),
                          leading: const Icon(Icons.drag_handle),
                          title: Text(draft[index]),
                          trailing: IconButton(
                            tooltip: 'Bỏ ghim',
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                update(() => draft.removeAt(index)),
                          ),
                        ),
                      ),
                      const Divider(),
                      for (final item in widget.items.where(
                        (e) => !draft.contains(e['label']),
                      ))
                        ListTile(
                          leading: Icon(
                            item['icon'] as IconData,
                            color: Colors.purple,
                          ),
                          title: Text(item['label'] as String),
                          trailing: const Icon(Icons.add_circle_outline),
                          enabled: draft.length < 8,
                          onTap: () =>
                              update(() => draft.add(item['label'] as String)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (saved == null || !mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setStringList(storageKey, saved)) {
        throw StateError('save');
      }
      if (mounted) setState(() => _favorites = [...saved]);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa lưu được dịch vụ yêu thích. Vui lòng thử lại.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeServiceQuery(_query);
    const aliases = {
      'Viễn thông': 'nap dien thoai the cao',
      'Hóa đơn': 'dien nuoc hoc phi',
      'Du lịch, đi lại': 've xe tau may bay',
    };
    final results = widget.items
        .where(
          (item) => normalizeServiceQuery(
            '${item['label']} ${aliases[item['label']] ?? ''}',
          ).contains(query),
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Tìm dịch vụ: điện, nạp điện thoại, vé xe…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (query.isNotEmpty) ...[
            if (results.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Không tìm thấy dịch vụ phù hợp.'),
              ),
            for (final item in results)
              ListTile(
                leading: Icon(item['icon'] as IconData),
                title: Text(item['label'] as String),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => widget.onOpen(item),
              ),
          ] else ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Dịch vụ yêu thích',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: _ready ? _edit : null,
                  child: const Text('Chỉnh sửa'),
                ),
              ],
            ),
            if (_favorites.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Ghim tối đa 8 dịch vụ để mở nhanh.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in _favorites)
                  InputChip(
                    avatar: Icon(
                      widget.items.firstWhere(
                            (e) => e['label'] == label,
                          )['icon']
                          as IconData,
                      size: 18,
                      color: Colors.purple,
                    ),
                    label: Text(label),
                    onPressed: () => widget.onOpen(
                      widget.items.firstWhere((e) => e['label'] == label),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
