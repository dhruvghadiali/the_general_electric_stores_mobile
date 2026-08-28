import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/core/constants/user_role.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/views/employee_contacts_view.dart';
import 'package:the_general_electric_stores_mobile/features/contacts/views/super_admin_contacts_view.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/employee_dashboard_view.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/super_admin_dashboard_view.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/warehouse_dashboard_view.dart';
import 'package:the_general_electric_stores_mobile/features/products/views/employee_products_view.dart';
import 'package:the_general_electric_stores_mobile/features/products/views/super_admin_products_view.dart';
import 'package:the_general_electric_stores_mobile/features/settings/views/settings_view.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/views/warehouse_stocks_view.dart';

/// Maps (role, destination) to the screen that role sees there.
///
/// Super admin and employee share tab *names* but not screens: each pairing
/// below resolves to its own widget, so a change to the employee product list
/// cannot alter what a super admin sees. Settings is the one screen genuinely
/// shared by all three — it shows the signed-in user and signs them out, which
/// is the same job for everyone.
///
/// A pairing that is not in `RoleNavigation` never reaches here, because the
/// shell only builds destinations that role owns. The fallback exists so a new
/// destination added to the enum but not wired up fails loudly in development
/// rather than rendering a blank tab.
class RoleScreens {
  const RoleScreens._();

  static Widget build(UserRole role, AppDestination destination) {
    return switch ((role, destination)) {
      // ------------------------------------------------------- super admin
      (UserRole.superAdmin, AppDestination.dashboard) =>
        const SuperAdminDashboardView(),
      (UserRole.superAdmin, AppDestination.products) =>
        const SuperAdminProductsView(),
      (UserRole.superAdmin, AppDestination.contacts) =>
        const SuperAdminContactsView(),

      // ---------------------------------------------------------- employee
      (UserRole.employee, AppDestination.dashboard) =>
        const EmployeeDashboardView(),
      (UserRole.employee, AppDestination.products) =>
        const EmployeeProductsView(),
      (UserRole.employee, AppDestination.contacts) =>
        const EmployeeContactsView(),

      // ------------------------------------------------- warehouse manager
      (UserRole.warehouseManager, AppDestination.dashboard) =>
        const WarehouseDashboardView(),
      (UserRole.warehouseManager, AppDestination.stocks) =>
        const WarehouseStocksView(),

      // ------------------------------------------------------------ shared
      (_, AppDestination.settings) => const SettingsView(),

      _ => _Unwired(role: role, destination: destination),
    };
  }
}

class _Unwired extends StatelessWidget {
  const _Unwired({required this.role, required this.destination});

  final UserRole role;
  final AppDestination destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(destination.label)),
      body: Center(
        child: Text(
          '${destination.label} is not wired up for ${role.label}.\n'
          'Add the pairing in RoleScreens.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
