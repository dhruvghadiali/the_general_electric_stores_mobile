import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_general_electric_stores_mobile/app/theme/app_colors.dart';
import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/warehouse_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/dashboard_scaffold.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/scan_card.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_grid.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_tile.dart';

class WarehouseDashboardView extends GetView<WarehouseDashboardController> {
  const WarehouseDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DashboardScaffold(
        controller: controller,
        children: <Widget>[
          ScanCard(onTap: controller.openScanner),
          const SizedBox(height: AppDimens.xl),
          StatGrid(
            children: <Widget>[
              StatTile(
                label: 'Stock lines',
                value: controller.totalStockLines,
                icon: Icons.warehouse_outlined,
                onTap: () => {},
              ),
              StatTile(
                label: 'Low stock',
                value: controller.lowStock,
                icon: Icons.trending_down_rounded,
                tone: AppColors.warning,
                onTap: () => {},
              ),
              StatTile(
                label: 'Out of stock',
                value: controller.outOfStock,
                icon: Icons.remove_shopping_cart_outlined,
                tone: AppColors.error,
                onTap: () => {},
              ),
              StatTile(
                label: 'Pending dispatch',
                value: controller.pendingDispatch,
                icon: Icons.local_shipping_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
