import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/routes/app_routes.dart';
import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/base_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';

/// The employee's view: what they can sell and who they can sell it to.
class EmployeeDashboardController extends BaseDashboardController {
  EmployeeDashboardController(DashboardRepository repository, UserRole role)
      : super(repository, role);

  num? get totalProducts =>
      summary.value.read(<String>['products_total', 'total_products', 'products']);

  num? get totalContacts =>
      summary.value.read(<String>['contacts_total', 'total_contacts', 'contacts']);

  num? get myOrders =>
      summary.value.read(<String>['my_orders', 'orders_total', 'orders']);

  /// A scanned sticker is a product for an employee too — the same route, but
  /// the employee's own read-only product screen behind it.
  @override
  void onScanned(String code) =>
      Get.toNamed<void>(AppRoutes.productDetailPath(idFromCode(code)));
}
