/// The `pagination` block every list endpoint returns
/// (`build_pagination(page, limit, total)` on the API side).
///
/// The key names the server uses are read defensively: whichever of
/// `total_pages` / `totalPages` / `pages` is present wins, so a rename on the
/// API does not silently produce a zero-page list.
class Pagination {
  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  static const Pagination empty =
      Pagination(page: 1, limit: 20, total: 0, totalPages: 0);

  bool get hasNextPage => page < totalPages;

  int get nextPage => hasNextPage ? page + 1 : page;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    final int page = _int(json, const <String>['page', 'current_page'], 1);
    final int limit =
        _int(json, const <String>['limit', 'per_page', 'page_size'], 20);
    final int total =
        _int(json, const <String>['total', 'total_records', 'count'], 0);
    final int totalPages = _int(
      json,
      const <String>['total_pages', 'totalPages', 'pages'],
      limit > 0 ? (total / limit).ceil() : 0,
    );

    return Pagination(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'page': page,
        'limit': limit,
        'total': total,
        'total_pages': totalPages,
      };

  static int _int(Map<String, dynamic> json, List<String> keys, int fallback) {
    for (final String key in keys) {
      final Object? value = json[key];
      if (value is num) return value.toInt();
      if (value is String) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return fallback;
  }

  @override
  String toString() =>
      'Pagination(page: $page, limit: $limit, total: $total, '
      'totalPages: $totalPages)';
}
