import 'package:the_general_electric_stores_mobile/core/constants/app_constants.dart';

enum SortOrder {
  asc,
  desc;

  String get value => name;
}

/// The query string of a list ("get all") endpoint.
///
/// The API validates every key against that resource's list config and answers
/// a 400 for anything out of contract, so this object exists to make the legal
/// shape obvious at the call site rather than to guess at what is allowed.
///
/// `sort` and `sort_by` are mutually exclusive on the server (`.oxor`), so only
/// one of them is ever emitted: [sort] wins when both are set.
class ListQuery {
  const ListQuery({
    this.page = AppConstants.defaultPage,
    this.limit = AppConstants.defaultPageLimit,
    this.search,
    this.sortBy,
    this.sortOrder = SortOrder.asc,
    this.sort,
    this.filters = const <String, dynamic>{},
  });

  final int page;
  final int limit;

  /// Free-text search, matched against the resource's `search_fields`.
  final String? search;

  /// Single-column sort: `?sort_by=name&sort_order=asc`.
  final String? sortBy;
  final SortOrder sortOrder;

  /// Multi-column sort: `?sort=name:asc,created_at:desc`.
  final List<String>? sort;

  /// Whitelisted filters for this resource, e.g. `{'is_active': true}`.
  final Map<String, dynamic> filters;

  ListQuery copyWith({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    SortOrder? sortOrder,
    List<String>? sort,
    Map<String, dynamic>? filters,
  }) {
    return ListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      sort: sort ?? this.sort,
      filters: filters ?? this.filters,
    );
  }

  ListQuery nextPage() => copyWith(page: page + 1);

  ListQuery firstPage() => copyWith(page: AppConstants.defaultPage);

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = <String, dynamic>{
      'page': page < 1 ? AppConstants.defaultPage : page,
      'limit': limit.clamp(1, AppConstants.maxPageLimit),
    };

    final String? term = search?.trim();
    if (term != null && term.isNotEmpty) {
      params['search'] = term;
    }

    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!.join(',');
    } else if (sortBy != null && sortBy!.isNotEmpty) {
      params['sort_by'] = sortBy;
      params['sort_order'] = sortOrder.value;
    }

    filters.forEach((String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      params[key] = value;
    });

    return params;
  }

  @override
  String toString() => 'ListQuery(${toQueryParameters()})';
}
