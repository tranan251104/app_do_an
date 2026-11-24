import 'package:flutter/material.dart';

String _normalizeServiceQuery(String value) {
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

class ServiceSearchEntry {
  final String label;
  final IconData icon;
  final String? category;
  final String keywords;
  final VoidCallback onOpen;

  const ServiceSearchEntry({
    required this.label,
    required this.icon,
    this.category,
    this.keywords = '',
    required this.onOpen,
  });
}

class ServiceSearch extends StatefulWidget {
  final List<ServiceSearchEntry> entries;

  const ServiceSearch({super.key, required this.entries});

  @override
  State<ServiceSearch> createState() => _ServiceSearchState();
}

class _ServiceSearchState extends State<ServiceSearch> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _normalizeServiceQuery(_controller.text);
    final terms = query.split(RegExp(r'\s+'));
    final results = [
      if (query.isNotEmpty)
        for (final entry in widget.entries)
          if (terms.every(
            _normalizeServiceQuery(
              '${entry.label} ${entry.category ?? ''} ${entry.keywords}',
            ).contains,
          ))
            entry,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tìm dịch vụ: điện, nạp điện thoại, vé xe…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () => setState(_controller.clear),
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (query.isNotEmpty && results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Không tìm thấy dịch vụ phù hợp.'),
            ),
          for (final result in results)
            ListTile(
              leading: Icon(result.icon, color: Colors.purple),
              title: Text(result.label),
              subtitle: result.category == null ? null : Text(result.category!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                FocusScope.of(context).unfocus();
                result.onOpen();
              },
            ),
        ],
      ),
    );
  }
}
