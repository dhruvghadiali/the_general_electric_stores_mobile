import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/super_admin_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/dashboard_scaffold.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_grid.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_tile.dart';

class SuperAdminDashboardView extends GetView<SuperAdminDashboardController> {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DashboardScaffold(
        controller: controller,
        children: <Widget>[
          StatGrid(
            children: <Widget>[
              StatTile(
                label: 'Products',
                value: controller.totalProducts,
                icon: Icons.inventory_2_outlined,
                onTap: () => {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
