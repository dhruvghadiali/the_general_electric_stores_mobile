import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/network/api_client.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/controllers/employee_contacts_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/controllers/super_admin_contacts_controller.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/data/repositories/contact_repository.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/employee_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/super_admin_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/warehouse_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:the_general_electric_stores_mobile/features/products/controllers/employee_products_controller.dart';
import 'package:the_general_electric_stores_mobile/features/products/controllers/super_admin_products_controller.dart';
import 'package:the_general_electric_stores_mobile/features/products/data/repositories/product_repository.dart';
import 'package:the_general_electric_stores_mobile/features/settings/controllers/settings_controller.dart';
import 'package:the_general_electric_stores_mobile/features/shell/controllers/shell_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/controllers/warehouse_stocks_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/repositories/stock_repository.dart';

/// One binding per role shell.
///
/// This is where role isolation is most concrete: a super admin's process never
/// constructs `WarehouseStocksController`, because nothing registers it. A
/// screen that somehow got built for the wrong role would throw on `Get.find`
/// rather than quietly fetching another role's data.
///
/// Controllers are eager (`put`, not `lazyPut`) because the shell's
/// `IndexedStack` builds every tab on the first frame.
abstract class _RoleShellBinding extends Bindings {
  _RoleShellBinding(this.role);

  final UserRole role;

  /// Shared by every shell: the tab index, and settings.
  ///
  /// No `AuthRepository` here any more. The only auth call the API has is
  /// signin, which belongs to the login screen; settings signs out locally and
  /// has nothing to ask the server for.
  void _common() {
    Get.put<ShellController>(ShellController(role));
    Get.put<SettingsController>(SettingsController(role));
  }
}

class SuperAdminShellBinding extends _RoleShellBinding {
  SuperAdminShellBinding() : super(UserRole.superAdmin);

  @override
  void dependencies() {
    _common();

    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<ContactRepository>(
      () => ContactRepository(ApiClient.to),
      fenix: true,
    );

    Get.put<SuperAdminDashboardController>(
      SuperAdminDashboardController(Get.find(), role),
    );
    Get.put<SuperAdminProductsController>(
      SuperAdminProductsController(Get.find(), role),
    );
    Get.put<SuperAdminContactsController>(
      SuperAdminContactsController(Get.find(), role),
    );
  }
}

class EmployeeShellBinding extends _RoleShellBinding {
  EmployeeShellBinding() : super(UserRole.employee);

  @override
  void dependencies() {
    _common();

    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<ContactRepository>(
      () => ContactRepository(ApiClient.to),
      fenix: true,
    );

    Get.put<EmployeeDashboardController>(
      EmployeeDashboardController(Get.find(), role),
    );
    Get.put<EmployeeProductsController>(
      EmployeeProductsController(Get.find(), role),
    );
    Get.put<EmployeeContactsController>(
      EmployeeContactsController(Get.find(), role),
    );
  }
}

class WarehouseShellBinding extends _RoleShellBinding {
  WarehouseShellBinding() : super(UserRole.warehouseManager);

  @override
  void dependencies() {
    _common();

    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(ApiClient.to),
      fenix: true,
    );
    Get.lazyPut<StockRepository>(
      () => StockRepository(ApiClient.to),
      fenix: true,
    );

    Get.put<WarehouseDashboardController>(
      WarehouseDashboardController(Get.find(), role),
    );
    Get.put<WarehouseStocksController>(
      WarehouseStocksController(Get.find(), role),
    );
  }
}
