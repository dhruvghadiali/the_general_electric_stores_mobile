import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_colors.dart';
import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/core/utils/formatters.dart';
import 'package:the_general_electric_stores_mobile/features/stocks/data/models/stock_model.dart';

class StockCard extends StatelessWidget {
  const StockCard({required this.stock, super.key, this.onTap});

  final StockModel stock;
  final VoidCallback? onTap;

  Color _tone(ThemeData theme) {
    switch (stock.status) {
      case StockStatus.healthy:
        return AppColors.success;
      case StockStatus.low:
        return AppColors.warning;
      case StockStatus.out:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color tone = _tone(theme);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      stock.name.isEmpty ? 'Unnamed item' : stock.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (stock.sku != null || stock.warehouse != null) ...[
                      const SizedBox(height: AppDimens.xxs),
                      Text(
                        <String?>[stock.sku, stock.warehouse]
                            .whereType<String>()
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimens.sm),
                    Row(
                      children: <Widget>[
                        Text(
                          stock.status.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: tone,
                          ),
                        ),
                        if (stock.reserved > 0) ...<Widget>[
                          const SizedBox(width: AppDimens.sm),
                          Text(
                            '${Formatters.quantity(stock.reserved)} reserved',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Formatters.quantity(stock.quantity),
                    style: theme.textTheme.titleMedium?.copyWith(color: tone),
                  ),
                  Text(
                    stock.unit ?? 'units',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
