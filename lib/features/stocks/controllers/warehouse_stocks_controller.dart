import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/controllers/base_list_controller.dart';
import 'package:the_general_electric_stores_mobile/core/models/list_query.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_response.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/models/stock_model.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/repositories/stock_repository.dart';

/// Stock lines for the warehouse manager.
///
/// The filter chips are the point of this screen: what needs reordering is
/// more useful than the full list, so [StockFilter] is part of the controller
/// rather than something the view assembles.
class WarehouseStocksController extends BaseListController<StockModel> {
  WarehouseStocksController(this._repository, this.role);

  final StockRepository _repository;
  final UserRole role;

  final Rx<StockFilter> filter = StockFilter.all.obs;

  @override
  Future<PaginatedResult<StockModel>> fetchPage(ListQuery query) =>
      _repository.list(role, query);

  void openStock(StockModel stock) =>
      Get.toNamed<void>(AppRoutes.stockDetailPath(stock.id));

  /// The server owns the real filtering — these keys have to exist in the
  /// stock resource's filter config or the request comes back a 400.
  void applyStockFilter(StockFilter value) {
    filter.value = value;
    switch (value) {
      case StockFilter.all:
        applyFilters(<String, dynamic>{});
      case StockFilter.low:
        applyFilters(<String, dynamic>{'status': 'low'});
      case StockFilter.out:
        applyFilters(<String, dynamic>{'status': 'out'});
    }
  }

  void sortByQuantityLowToHigh() => sortBy('quantity');

  void sortByRecentlyUpdated() => sortBy('updated_at', order: SortOrder.desc);
}

enum StockFilter {
  all('All'),
  low('Low'),
  out('Out of stock');

  const StockFilter(this.label);

  final String label;
}
