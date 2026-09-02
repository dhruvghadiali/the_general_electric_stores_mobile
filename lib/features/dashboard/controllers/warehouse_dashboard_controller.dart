import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/base_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';

/// The warehouse manager's view: what is on the shelf and what needs ordering.
/// No revenue, no contacts — nothing outside the warehouse.
class WarehouseDashboardController extends BaseDashboardController {
  WarehouseDashboardController(super.repository, super.role);

  num? get totalStockLines =>
      summary.value.read(<String>['stocks_total', 'total_stocks', 'stocks']);

  num? get lowStock => summary.value
      .read(<String>['stocks_low', 'low_stock', 'low_stock_count']);

  num? get outOfStock => summary.value
      .read(<String>['stocks_out', 'out_of_stock', 'out_of_stock_count']);

  num? get pendingDispatch => summary.value
      .read(<String>['pending_dispatch', 'dispatch_pending', 'pending']);
}
