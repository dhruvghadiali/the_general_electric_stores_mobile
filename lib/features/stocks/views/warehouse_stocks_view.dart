import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/paged_list_view.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/controllers/warehouse_stocks_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/models/stock_model.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/widgets/stock_card.dart';

/// The warehouse manager's only list screen. The filter chips are the working
/// tool here — "what needs reordering" is the question this screen exists to
/// answer, so it is one tap from the top rather than buried in a sort sheet.
class WarehouseStocksView extends GetView<WarehouseStocksController> {
  const WarehouseStocksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _showSortSheet(context),
            icon: const Icon(Icons.swap_vert_rounded),
            tooltip: 'Sort',
          ),
        ],
        bottom: ListSearchBar(
          hintText: 'Search stock',
          onChanged: controller.search,
        ),
      ),
      body: PagedListView<StockModel>(
        controller: controller,
        loadingMessage: 'Loading stock…',
        emptyTitle: 'Nothing to show',
        emptyMessage: 'No stock lines matched this filter.',
        emptyIcon: Icons.warehouse_outlined,
        totalLabel: 'stock lines',
        header: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            AppDimens.sm,
            AppDimens.screenPadding,
            0,
          ),
          child: Obx(
            () => Row(
              children: StockFilter.values
                  .map(
                    (StockFilter filter) => Padding(
                      padding: const EdgeInsets.only(right: AppDimens.sm),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: controller.filter.value == filter,
                        onSelected: (_) => controller.applyStockFilter(filter),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
        itemBuilder: (BuildContext context, StockModel stock) => StockCard(
          stock: stock,
          onTap: () => controller.openStock(stock),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    Get.bottomSheet<void>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: AppDimens.sm),
            ListTile(
              leading: const Icon(Icons.arrow_upward_rounded),
              title: const Text('Quantity: low to high'),
              onTap: () {
                Get.back<void>();
                controller.sortByQuantityLowToHigh();
              },
            ),
            ListTile(
              leading: const Icon(Icons.update_rounded),
              title: const Text('Recently updated'),
              onTap: () {
                Get.back<void>();
                controller.sortByRecentlyUpdated();
              },
            ),
            const SizedBox(height: AppDimens.sm),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
