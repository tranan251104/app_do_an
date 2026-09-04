class PagedResult<T> {
  final List<T> items;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;
  final bool last;

  const PagedResult({
    required this.items,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  bool get hasMore => !last && page + 1 < totalPages;

  factory PagedResult.fromSpringPage(
    Map<String, dynamic>? envelope,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final content = envelope?['content'];
    final items = (content as List? ?? const [])
        .whereType<Map>()
        .map((item) => mapper(Map<String, dynamic>.from(item)))
        .toList();

    final page = (envelope?['number'] as num?)?.toInt() ?? 0;
    final size = (envelope?['size'] as num?)?.toInt() ?? items.length;
    final totalPages = (envelope?['totalPages'] as num?)?.toInt() ??
        (items.isEmpty ? 0 : page + 1);
    final totalElements = (envelope?['totalElements'] as num?)?.toInt() ??
        items.length;
    final lastValue = envelope?['last'];
    final last = lastValue is bool
        ? lastValue
        : totalPages == 0 || page >= totalPages - 1;

    return PagedResult<T>(
      items: items,
      page: page,
      size: size,
      totalPages: totalPages,
      totalElements: totalElements,
      last: last,
    );
  }
}
