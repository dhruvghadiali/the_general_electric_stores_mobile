import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/base_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';

/// The employee's view: what they can sell and who they can sell it to.
class EmployeeDashboardController extends BaseDashboardController {
  EmployeeDashboardController(super.repository, super.role);

  num? get totalProducts => summary.value
      .read(<String>['products_total', 'total_products', 'products']);

  num? get totalContacts => summary.value
      .read(<String>['contacts_total', 'total_contacts', 'contacts']);

  num? get myOrders =>
      summary.value.read(<String>['my_orders', 'orders_total', 'orders']);
}
