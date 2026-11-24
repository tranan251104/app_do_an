import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _ready = false;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    widget.items.firstWhere((e) => e['label'] == label)['icon']
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
      ),
    );
  }
}
