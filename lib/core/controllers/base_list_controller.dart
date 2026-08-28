import 'dart:async';

import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/app_constants.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/models/pagination.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_exception.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/core/utils/logger.dart';

/// Shared behaviour for every screen backed by a list ("get all") endpoint:
/// first load, pull-to-refresh, infinite scroll, debounced search and sort.
///
/// A feature subclasses this and implements [fetchPage] — nothing else. The
/// paging rules live here once so two screens can never disagree about when
/// the last page has been reached.
abstract class BaseListController<T> extends GetxController {
  final RxList<T> items = <T>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isRefreshing = false.obs;
  final Rxn<ApiException> failure = Rxn<ApiException>();
  final Rx<Pagination> pagination = Pagination.empty.obs;

  ListQuery query = const ListQuery();

  Timer? _debounce;

  bool get isEmpty => items.isEmpty && !isLoading.value;

  bool get hasFailed => failure.value != null;

  bool get canLoadMore => pagination.value.hasNextPage && !isLoadingMore.value;

  /// One page from the API. The subclass supplies the endpoint and the parser.
  Future<PaginatedResult<T>> fetchPage(ListQuery query);

  @override
  void onInit() {
    super.onInit();
    unawaited(load());
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// First load, and the retry after a failure.
  Future<void> load() async {
    isLoading.value = true;
    failure.value = null;
    query = query.firstPage();

    try {
      final PaginatedResult<T> page = await fetchPage(query);
      items.assignAll(page.items);
      pagination.value = page.pagination;
    } on ApiException catch (error) {
      failure.value = error;
      items.clear();
    } on Object catch (error, stackTrace) {
      AppLogger.e('Unexpected list failure', error, stackTrace);
      failure.value = ApiException(message: error.toString());
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh: keeps what is on screen until the new page arrives.
  Future<void> refreshList() async {
    isRefreshing.value = true;
    query = query.firstPage();

    try {
      final PaginatedResult<T> page = await fetchPage(query);
      items.assignAll(page.items);
      pagination.value = page.pagination;
      failure.value = null;
    } on ApiException catch (error) {
      failure.value = error;
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Next page for infinite scroll. A no-op on the last page.
  Future<void> loadMore() async {
    if (!canLoadMore || isLoading.value) return;

    isLoadingMore.value = true;
    final ListQuery next = query.nextPage();

    try {
      final PaginatedResult<T> page = await fetchPage(next);
      query = next;
      items.addAll(page.items);
      pagination.value = page.pagination;
    } on ApiException catch (error) {
      // A failed page does not wipe the ones already on screen.
      AppLogger.w('Could not load page ${next.page}: ${error.message}');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Debounced search. Safe to call on every keystroke.
  void search(String term) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () {
      query = query.copyWith(search: term, page: AppConstants.defaultPage);
      unawaited(load());
    });
  }

  void sortBy(String field, {SortOrder order = SortOrder.asc}) {
    query = query.copyWith(
      sortBy: field,
      sortOrder: order,
      page: AppConstants.defaultPage,
    );
    unawaited(load());
  }

  void applyFilters(Map<String, dynamic> filters) {
    query = query.copyWith(filters: filters, page: AppConstants.defaultPage);
    unawaited(load());
  }

  void clearFilters() {
    query = const ListQuery();
    unawaited(load());
  }
}
