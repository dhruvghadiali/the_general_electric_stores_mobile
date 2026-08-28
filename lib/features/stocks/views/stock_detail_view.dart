import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_colors.dart';
import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';
import 'package:the_general_electric_stores_mobile/core/widgets/state_views.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/controllers/stock_detail_controller.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/models/stock_model.dart';

class StockDetailView extends GetView<StockDetailController> {
  const StockDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();

        if (controller.failure.value != null) {
          return ErrorView(
            error: controller.failure.value!,
            onRetry: controller.load,
          );
        }

        final StockModel? stock = controller.stock;
        if (stock == null) {
          return const EmptyView(title: 'This stock line no longer exists');
        }

        final Color tone = switch (stock.status) {
          StockStatus.healthy => AppColors.success,
          StockStatus.low => AppColors.warning,
          StockStatus.out => theme.colorScheme.error,
        };

        return ListView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          children: <Widget>[
            Text(stock.name, style: theme.textTheme.headlineSmall),
            if (stock.sku != null) ...<Widget>[
              const SizedBox(height: AppDimens.xs),
              Text(
                stock.sku!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.lg),
            Text(
              stock.status.label,
              style: theme.textTheme.titleMedium?.copyWith(color: tone),
            ),
            const SizedBox(height: AppDimens.xl),
            const Divider(),
            _Row(label: 'On hand', value: stock.quantityLabel),
            _Row(label: 'Reserved', value: Formatters.quantity(stock.reserved)),
            _Row(label: 'Available', value: Formatters.quantity(stock.available)),
            _Row(
              label: 'Reorder at',
              value: stock.reorderLevel == 0
                  ? '—'
                  : Formatters.quantity(stock.reorderLevel),
            ),
            _Row(label: 'Warehouse', value: stock.warehouse ?? '—'),
            _Row(
              label: 'Updated',
              value: Formatters.dateTime(stock.updatedAt),
            ),
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
