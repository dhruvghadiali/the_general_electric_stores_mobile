import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/employee_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/dashboard_scaffold.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_tile.dart';
import 'package:the_general_electric_stores_mobile/features/shell/controllers/shell_controller.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DashboardScaffold(
        controller: controller,
        title: 'Your day',
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
                label: 'Your orders',
                value: controller.myOrders,
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
