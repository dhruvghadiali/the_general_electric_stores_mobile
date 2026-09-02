import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/base_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';

/// The super admin's view of the business: catalogue size, the contact book,
/// and who is using the system.
class SuperAdminDashboardController extends BaseDashboardController {
  SuperAdminDashboardController(super.repository, super.role);

  num? get totalProducts => summary.value
      .read(<String>['products_total', 'total_products', 'products']);

  num? get totalContacts => summary.value
      .read(<String>['contacts_total', 'total_contacts', 'contacts']);

  num? get totalEmployees => summary.value
      .read(<String>['employees_total', 'total_employees', 'employees']);

  num? get totalOrders =>
      summary.value.read(<String>['orders_total', 'total_orders', 'orders']);
}
