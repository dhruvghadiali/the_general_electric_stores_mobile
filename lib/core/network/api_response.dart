import 'package:the_general_electric_stores_mobile/core/models/pagination.dart';

/// `send_response` normalises `data` server-side: a single document comes back
/// wrapped in a list, an empty result becomes `[]`, and an action with several
/// values returns one object. This unwraps the first two cases.
///
/// Every repository that parses a single record uses this rather than keeping
/// its own copy — the wrapping rule is the API's, so it belongs in one place.
Map<String, dynamic> firstObject(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is List && data.isNotEmpty) {
    final Object? first = data.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
  }
  return const <String, dynamic>{};
}

/// The envelope every endpoint answers with
/// (`send_response(res, status, message, data)`).
class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;

  /// The server's own wording, ready to show a user after a write.
  final String message;

  /// The parsed payload, when a parser was supplied.
  final T? data;

  /// Builds the envelope from a decoded response body.
  ///
  /// [parser] receives the raw `data` member and returns the typed payload.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode, {
    T Function(Object? data)? parser,
  }) {
    final Object? payload = json.containsKey('data') ? json['data'] : json;
    final Object? message = json['message'];

    return ApiResponse<T>(
      statusCode: _statusOf(json, statusCode),
      message: message is String ? message : '',
      data: parser == null ? null : parser(payload),
    );
  }

  static int _statusOf(Map<String, dynamic> json, int fallback) {
    for (final String key in const <String>['status', 'status_code', 'code']) {
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
  String toString() => 'ApiResponse($statusCode, "$message")';
}

/// One page of a list endpoint: the rows plus the `pagination` block that came
/// alongside them.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final Pagination pagination;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// Reads `{ <itemsKey>: [...], pagination: {...} }`.
  ///
  /// [itemsKey] is the plural name the controller used — `products`,
  /// `contacts`, `companies`. Three shapes arrive here and all three are real:
  ///
  /// ```
  /// data: { companies: [...], pagination: {...} }     the composite
  /// data: [ { companies: [...], pagination: {...} } ] the composite, wrapped
  /// data: [ {...}, {...} ]                            a bare array of rows
  /// ```
  ///
  /// The middle one is what `send_response` produces — it wraps whatever it is
  /// given in a list. Unwrapping is deliberately conditional on the first
  /// element carrying [itemsKey] or `pagination`: a bare array holding exactly
  /// one row looks identical otherwise, and would be read as an empty page.
  factory PaginatedResult.fromData(
    Object? data, {
    required String itemsKey,
    required T Function(Map<String, dynamic> json) parser,
  }) {
    Object? node = data;
    if (node is List && node.isNotEmpty) {
      final Object? first = node.first;
      if (first is Map<String, dynamic> &&
          (first.containsKey(itemsKey) || first.containsKey('pagination'))) {
        node = first;
      }
    }

    if (node is List) {
      final List<T> items = node
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList(growable: false);
      return PaginatedResult<T>(
        items: items,
        pagination: Pagination(
          page: 1,
          limit: items.length,
          total: items.length,
          totalPages: items.isEmpty ? 0 : 1,
        ),
      );
    }

    if (node is Map<String, dynamic>) {
      final Object? rows = node[itemsKey] ?? node['items'] ?? node['records'];
      final Object? page = node['pagination'];

      return PaginatedResult<T>(
        items: rows is List
            ? rows
                .whereType<Map<String, dynamic>>()
                .map(parser)
                .toList(growable: false)
            : const <Never>[],
        pagination: page is Map<String, dynamic>
            ? Pagination.fromJson(page)
            : Pagination.empty,
      );
    }

    return PaginatedResult<T>(
      items: const <Never>[],
      pagination: Pagination.empty,
    );
  }
}
