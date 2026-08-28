import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/super_admin_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/dashboard_scaffold.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_tile.dart';
import 'package:the_general_electric_stores_mobile/features/shell/controllers/shell_controller.dart';

class SuperAdminDashboardView extends GetView<SuperAdminDashboardController> {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DashboardScaffold(
        controller: controller,
        title: 'Overview',
        children: <Widget>[
          StatGrid(
            children: <Widget>[
              StatTile(
                label: 'Products',
                value: controller.totalProducts,
                icon: Icons.inventory_2_outlined,
                onTap: () => Get.find<ShellController>()
                    .goTo(AppDestination.products),
              ),
              StatTile(
                label: 'Contacts',
                value: controller.totalContacts,
                icon: Icons.contacts_outlined,
                onTap: () => Get.find<ShellController>()
                    .goTo(AppDestination.contacts),
              ),
              StatTile(
                label: 'Employees',
                value: controller.totalEmployees,
                icon: Icons.groups_outlined,
              ),
              StatTile(
                label: 'Orders',
                value: controller.totalOrders,
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
