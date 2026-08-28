import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_colors.dart';
import 'package:the_general_electric_stores_mobile/core/navigation/app_destination.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/controllers/warehouse_dashboard_controller.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/dashboard_scaffold.dart';
import 'package:the_general_electric_stores_mobile/features/dashboard/views/widgets/stat_tile.dart';
import 'package:the_general_electric_stores_mobile/features/shell/controllers/shell_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/controllers/warehouse_stocks_controller.dart';

class WarehouseDashboardView extends GetView<WarehouseDashboardController> {
  const WarehouseDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DashboardScaffold(
        controller: controller,
        title: 'Warehouse',
        children: <Widget>[
          StatGrid(
            children: <Widget>[
              StatTile(
                label: 'Stock lines',
                value: controller.totalStockLines,
                icon: Icons.warehouse_outlined,
                onTap: () => _openStocks(StockFilter.all),
              ),
              StatTile(
                label: 'Low stock',
                value: controller.lowStock,
                icon: Icons.trending_down_rounded,
                tone: AppColors.warning,
                onTap: () => _openStocks(StockFilter.low),
              ),
              StatTile(
                label: 'Out of stock',
                value: controller.outOfStock,
                icon: Icons.remove_shopping_cart_outlined,
                tone: AppColors.error,
                onTap: () => _openStocks(StockFilter.out),
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

  /// Jumps to the stocks tab with the filter already applied — the point of a
  /// "low stock" figure is to act on it.
  void _openStocks(StockFilter filter) {
    Get.find<WarehouseStocksController>().applyStockFilter(filter);
    Get.find<ShellController>().goTo(AppDestination.stocks);
  }
}
