import 'package:flutter/material.dart';

import 'package:the_general_electric_stores_mobile/app/theme/app_dimens.dart';
import 'package:the_general_electric_stores_mobile/features/scanner/constants/scan_purpose.dart';

/// One of the two choices on the purpose screen: a large, gloved-hand-sized
/// target carrying the purpose's own icon, label and description.
class PurposeCard extends StatelessWidget {
  const PurposeCard({required this.purpose, required this.onTap, super.key});

  final ScanPurpose purpose;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Row(
            children: <Widget>[
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(
                  purpose.icon,
                  size: AppDimens.iconLg,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppDimens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(purpose.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppDimens.xxs),
                    Text(
                      purpose.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
